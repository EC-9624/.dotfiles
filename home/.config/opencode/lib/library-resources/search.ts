import { tool } from "@opencode-ai/plugin";
import { spawnSync } from "child_process";
import * as fs from "fs";

import type { Resource } from "./types";
import type { ResourcePaths } from "./paths";
import { getResourcePath } from "./paths";
import { getMergedResources, getSelectedResources } from "./registry";
import { getErrorMessage, isCommandMissing } from "./errors";

const SEARCH_MAX_MATCHES = 200;
const SEARCH_MAX_MATCHES_PER_FILE = 20;
const SEARCH_MAX_LINE_LENGTH = 400;
const SEARCH_EXCLUDE_GLOBS = [
  "!.git/**",
  "!node_modules/**",
  "!dist/**",
  "!build/**",
  "!coverage/**",
];
const SEARCH_EXCLUDE_DIRS = [
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
];

interface SearchableResource {
  resource: Resource;
  repoPath: string;
}

interface ParsedResult {
  groupedResults: Map<string, string[]>;
  truncated: boolean;
}

interface CreateSearchToolOptions {
  paths: ResourcePaths;
}

const buildSearchableResources = (
  resources: Resource[],
  paths: ResourcePaths
): SearchableResource[] => {
  return resources
    .map((resource) => ({
      resource,
      repoPath: getResourcePath(paths, resource),
    }))
    .filter(({ repoPath }) => fs.existsSync(repoPath));
};

const runRipgrep = (
  query: string,
  include: string | undefined,
  searchableResources: SearchableResource[]
) => {
  const args = [
    "--line-number",
    "--with-filename",
    "--no-heading",
    "--color=never",
    "--ignore-case",
    "--max-count",
    String(SEARCH_MAX_MATCHES_PER_FILE),
  ];

  if (include) {
    args.push("-g", include);
  }
  for (const globPattern of SEARCH_EXCLUDE_GLOBS) {
    args.push("-g", globPattern);
  }
  args.push("--", query);
  for (const entry of searchableResources) {
    args.push(entry.repoPath);
  }

  return spawnSync("rg", args, {
    encoding: "utf-8",
    maxBuffer: 1024 * 1024 * 32,
  });
};

const runGrepFallback = (
  query: string,
  include: string | undefined,
  searchableResources: SearchableResource[]
) => {
  const args = ["-R", "-n", "-i", "-E", "--binary-files=without-match"];

  if (include) {
    args.push("--include", include);
  }
  for (const excludeDir of SEARCH_EXCLUDE_DIRS) {
    args.push(`--exclude-dir=${excludeDir}`);
  }

  args.push("--", query);
  for (const entry of searchableResources) {
    args.push(entry.repoPath);
  }

  return spawnSync("grep", args, {
    encoding: "utf-8",
    maxBuffer: 1024 * 1024 * 32,
  });
};

const resolveResourceOwner = (
  absoluteFilePath: string,
  searchableResources: SearchableResource[]
): SearchableResource | undefined => {
  for (const entry of searchableResources) {
    if (
      absoluteFilePath === entry.repoPath ||
      absoluteFilePath.startsWith(`${entry.repoPath}/`)
    ) {
      return entry;
    }
  }
  return undefined;
};

const parseResults = (
  stdout: string,
  searchableResources: SearchableResource[]
): ParsedResult => {
  const groupedResults = new Map<string, string[]>();
  for (const entry of searchableResources) {
    groupedResults.set(entry.resource.name, []);
  }

  let totalMatches = 0;
  let truncated = false;

  for (const line of stdout.split("\n")) {
    if (!line) {
      continue;
    }

    const match = line.match(/^(.*?):([0-9]+):(.*)$/);
    if (!match) {
      continue;
    }

    const [, absoluteFilePath, lineNumber, snippet] = match;
    const owner = resolveResourceOwner(absoluteFilePath, searchableResources);
    if (!owner) {
      continue;
    }

    const repoPrefix = `${owner.repoPath}/`;
    const relativePath = absoluteFilePath.startsWith(repoPrefix)
      ? absoluteFilePath.slice(repoPrefix.length)
      : absoluteFilePath;
    const safeSnippet =
      snippet.length > SEARCH_MAX_LINE_LENGTH
        ? `${snippet.slice(0, SEARCH_MAX_LINE_LENGTH)}...`
        : snippet;

    const bucket = groupedResults.get(owner.resource.name);
    if (!bucket) {
      continue;
    }

    bucket.push(`${relativePath}:${lineNumber}:${safeSnippet}`);
    totalMatches += 1;
    if (totalMatches >= SEARCH_MAX_MATCHES) {
      truncated = true;
      break;
    }
  }

  return { groupedResults, truncated };
};

const formatResults = (
  query: string,
  resources: SearchableResource[],
  groupedResults: Map<string, string[]>,
  truncated: boolean,
  usedFallback: boolean,
  selectedName?: string
): string => {
  const sections: string[] = [];
  for (const entry of resources) {
    const matches = groupedResults.get(entry.resource.name);
    if (!matches || matches.length === 0) {
      continue;
    }
    sections.push(`\n### ${entry.resource.name}\n\`\`\`\n${matches.join("\n")}\n\`\`\``);
  }

  if (sections.length === 0) {
    return `No matches found for "${query}"${
      selectedName ? ` in ${selectedName}` : ""
    }`;
  }

  const truncationNote = truncated
    ? `\n\n(truncated at ${SEARCH_MAX_MATCHES} matches)`
    : "";
  const fallbackNote = usedFallback
    ? "\n\n(Note: rg unavailable, used grep fallback)"
    : "";

  return `Search results for "${query}":${sections.join("\n")}${truncationNote}${fallbackNote}`;
};

export const createResourceSearchTool = ({ paths }: CreateSearchToolOptions) => {
  return tool({
    description: `Search for content within library resources.
If name is omitted, searches all resources.
Returns matching file paths and line snippets.`,
    args: {
      query: tool.schema.string().describe("Search pattern (supports regex)"),
      name: tool.schema
        .string()
        .optional()
        .describe("Resource name (optional, searches all if omitted)"),
      include: tool.schema
        .string()
        .optional()
        .describe("File pattern to include (e.g., '*.md', '*.ts')"),
    },
    async execute(args) {
      const { query, name, include } = args;
      const resources = name
        ? getSelectedResources(paths, name)
        : getMergedResources(paths);

      if (resources.length === 0) {
        return name ? `Resource '${name}' not found.` : "No resources available.";
      }

      const searchableResources = buildSearchableResources(resources, paths);
      if (searchableResources.length === 0) {
        return `No matches found for "${query}"${name ? ` in ${name}` : ""}`;
      }

      const rgResult = runRipgrep(query, include, searchableResources);
      let usedFallback = false;
      let stdout = "";

      if (rgResult.error && isCommandMissing(rgResult.error)) {
        usedFallback = true;
        const fallbackResult = runGrepFallback(query, include, searchableResources);

        if (fallbackResult.error) {
          return `Search failed: ${getErrorMessage(fallbackResult.error)}`;
        }
        if (fallbackResult.status !== 0 && fallbackResult.status !== 1) {
          const stderr = fallbackResult.stderr.trim();
          return `Search failed: ${
            stderr || `grep exited with code ${fallbackResult.status}`
          }`;
        }

        stdout = fallbackResult.stdout;
      } else {
        if (rgResult.error) {
          return `Search failed: ${getErrorMessage(rgResult.error)}`;
        }
        if (rgResult.status !== 0 && rgResult.status !== 1) {
          const stderr = rgResult.stderr.trim();
          return `Search failed: ${stderr || `rg exited with code ${rgResult.status}`}`;
        }

        stdout = rgResult.stdout;
      }

      const { groupedResults, truncated } = parseResults(stdout, searchableResources);

      return formatResults(
        query,
        searchableResources,
        groupedResults,
        truncated,
        usedFallback,
        name
      );
    },
  });
};
