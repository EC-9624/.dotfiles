import { tool } from "@opencode-ai/plugin";
import { spawnSync } from "child_process";
import * as fs from "fs";
import * as path from "path";

import { getErrorMessage, isCommandMissing } from "./errors";
import type { ResourcePaths } from "./paths";
import { getResourcePath } from "./paths";
import { findResource } from "./registry";

const TREE_MAX_FILES = 100;
const TREE_EXCLUDE_GLOBS = [
  "!.git/**",
  "!node_modules/**",
  "!dist/**",
  "!build/**",
  "!coverage/**",
];
const TREE_EXCLUDE_DIRS = new Set([
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
]);

const runRipgrepFiles = (targetPath: string, depth: number) => {
  const args = ["--files", "--hidden", "--max-depth", String(depth)];
  for (const globPattern of TREE_EXCLUDE_GLOBS) {
    args.push("-g", globPattern);
  }
  args.push(targetPath);

  return spawnSync("rg", args, {
    encoding: "utf-8",
    maxBuffer: 1024 * 1024 * 32,
  });
};

const listFilesWithFs = (targetPath: string, depth: number): string[] => {
  if (depth <= 0) {
    return [];
  }

  const files: string[] = [];
  const entries = fs.readdirSync(targetPath, { withFileTypes: true });

  for (const entry of entries) {
    if (TREE_EXCLUDE_DIRS.has(entry.name)) {
      continue;
    }

    const fullPath = path.join(targetPath, entry.name);
    if (entry.isFile()) {
      files.push(fullPath);
      continue;
    }

    if (entry.isDirectory()) {
      files.push(...listFilesWithFs(fullPath, depth - 1));
    }
  }

  return files;
};

const toRelativeSortedPaths = (stdout: string, repoPath: string): string[] => {
  const repoPrefix = `${repoPath}/`;
  return stdout
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => (line.startsWith(repoPrefix) ? line.slice(repoPrefix.length) : line))
    .sort();
};

interface CreateTreeToolOptions {
  paths: ResourcePaths;
}

export const createResourceTreeTool = ({ paths }: CreateTreeToolOptions) => {
  return tool({
    description: "List files and directories in a library resource",
    args: {
      name: tool.schema.string().describe("Resource name"),
      subpath: tool.schema
        .string()
        .optional()
        .describe("Subdirectory to list (optional)"),
      depth: tool.schema.number().optional().describe("Max depth (default: 3)"),
    },
    async execute(args) {
      const { name, subpath = "", depth = 3 } = args;
      const maxDepth = Math.max(0, Math.floor(depth));

      const resource = findResource(paths, name);
      if (!resource) {
        return `Resource '${name}' not found.`;
      }

      const repoPath = getResourcePath(paths, resource);
      if (!fs.existsSync(repoPath)) {
        return `Resource '${name}' is not cloned. Run '/resource restore ${name}' first.`;
      }

      const targetPath = path.join(repoPath, subpath);
      if (!fs.existsSync(targetPath)) {
        return `Path not found: ${subpath || "/"}`;
      }

      const rgResult = runRipgrepFiles(targetPath, maxDepth);

      let stdout = "";
      if (rgResult.error && isCommandMissing(rgResult.error)) {
        try {
          stdout = listFilesWithFs(targetPath, maxDepth).join("\n");
        } catch (error) {
          return `Error listing files: ${getErrorMessage(error)}`;
        }
      } else {
        if (rgResult.error) {
          return `Error listing files: ${getErrorMessage(rgResult.error)}`;
        }
        if (rgResult.status !== 0 && rgResult.status !== 1) {
          const stderr = rgResult.stderr.trim();
          return `Error listing files: ${
            stderr || `rg exited with code ${rgResult.status}`
          }`;
        }
        stdout = rgResult.stdout;
      }

      const lines = toRelativeSortedPaths(stdout, repoPath);

      if (lines.length === 0) {
        return `No files found in ${name}/${subpath}`;
      }

      const limitedLines = lines.slice(0, TREE_MAX_FILES);
      const header = subpath ? `${name}/${subpath}` : name;
      return `Files in ${header} (depth: ${maxDepth}):\n\n${limitedLines.join("\n")}${
        lines.length > TREE_MAX_FILES
          ? `\n\n(truncated at ${TREE_MAX_FILES} files)`
          : ""
      }`;
    },
  });
};
