import { tool } from "@opencode-ai/plugin";
import { spawnSync } from "child_process";
import * as fs from "fs";
import * as path from "path";

import { getErrorMessage, isCommandMissing } from "./errors";
import type { PluginContext } from "./context";
import {
  getRegistryPathForScope,
  getReposDirForScope,
  getResourcePath,
  type ResourcePaths,
} from "./paths";
import {
  ensureDir,
  findResource,
  getMergedResources,
  getSelectedResources,
  loadRegistry,
  saveRegistry,
  updateResourceTimestamp,
} from "./registry";
import type { ResourceScope } from "./types";

interface CreateManageToolOptions {
  ctx: PluginContext;
  paths: ResourcePaths;
}

const FILE_COUNT_EXCLUDE_GLOBS = [
  "!.git/**",
  "!node_modules/**",
  "!dist/**",
  "!build/**",
  "!coverage/**",
];

const FILE_COUNT_EXCLUDE_DIRS = new Set([
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
]);

const getRepoSize = async (ctx: PluginContext, repoPath: string): Promise<string> => {
  const sizeResult = await ctx.$`du -sh ${repoPath}`.text();
  return sizeResult.split("\t")[0] ?? "unknown";
};

const countFilesWithFs = (targetPath: string): number => {
  let total = 0;
  const entries = fs.readdirSync(targetPath, { withFileTypes: true });

  for (const entry of entries) {
    if (FILE_COUNT_EXCLUDE_DIRS.has(entry.name)) {
      continue;
    }

    const fullPath = path.join(targetPath, entry.name);
    if (entry.isDirectory()) {
      total += countFilesWithFs(fullPath);
      continue;
    }

    if (entry.isFile()) {
      total += 1;
    }
  }

  return total;
};

const getRepoFileCount = (repoPath: string): string => {
  const rgArgs = ["--files", "--hidden"];
  for (const globPattern of FILE_COUNT_EXCLUDE_GLOBS) {
    rgArgs.push("-g", globPattern);
  }
  rgArgs.push(repoPath);

  const rgResult = spawnSync("rg", rgArgs, {
    encoding: "utf-8",
    maxBuffer: 1024 * 1024 * 32,
  });

  if (rgResult.error) {
    if (isCommandMissing(rgResult.error)) {
      return String(countFilesWithFs(repoPath));
    }
    throw new Error(getErrorMessage(rgResult.error));
  }

  if (rgResult.status !== 0 && rgResult.status !== 1) {
    const stderr = rgResult.stderr.trim();
    throw new Error(stderr || `rg exited with code ${rgResult.status}`);
  }

  const lines = rgResult.stdout
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
  return String(lines.length);
};

const getScope = (project: boolean): ResourceScope => {
  return project ? "project" : "global";
};

export const createResourceManageTool = ({
  ctx,
  paths,
}: CreateManageToolOptions) => {
  return tool({
    description: `Manage library documentation resources.

Actions:
- add <name> <url> [branch] [notes] [--project]: Clone and register a resource
- remove <name>: Remove a resource
- list: List all resources (global + project merged)
- update [name]: Pull latest changes (all if no name specified)
- info <name>: Show resource details
- restore [name]: Re-clone missing repos from registry (useful after syncing config to new machine)`,
    args: {
      action: tool.schema.enum([
        "add",
        "remove",
        "list",
        "update",
        "info",
        "restore",
      ]),
      name: tool.schema.string().optional().describe("Resource name"),
      url: tool.schema.string().optional().describe("Git repository URL"),
      branch: tool.schema
        .string()
        .optional()
        .describe("Git branch (default: main)"),
      notes: tool.schema
        .string()
        .optional()
        .describe("Notes about the resource"),
      project: tool.schema
        .boolean()
        .optional()
        .describe("Store in project scope instead of global"),
    },
    async execute(args) {
      const {
        action,
        name,
        url,
        branch = "main",
        notes = "",
        project = false,
      } = args;

      switch (action) {
        case "add": {
          if (!name || !url) {
            return "Error: 'add' requires name and url.\nUsage: add <name> <url> [branch] [notes] [--project]";
          }

          const scope = getScope(project);
          const reposDir = getReposDirForScope(paths, scope);
          const registryPath = getRegistryPathForScope(paths, scope);
          const repoPath = path.join(reposDir, name);

          const existing = findResource(paths, name);
          if (existing) {
            return `Error: Resource '${name}' already exists (${existing.scope}). Remove it first or use a different name.`;
          }

          ensureDir(reposDir);

          try {
            const cloneResult = await ctx.$`git clone --branch ${branch} ${url} ${repoPath}`.quiet();
            if (cloneResult.exitCode !== 0) {
              return `Error cloning repository: ${cloneResult.stderr}`;
            }
          } catch (error) {
            return `Error cloning repository: ${getErrorMessage(error)}`;
          }

          const registry = loadRegistry(registryPath);
          const now = new Date().toISOString();
          registry.resources.push({
            name,
            url,
            branch,
            notes,
            scope,
            clonedAt: now,
            updatedAt: now,
          });
          saveRegistry(registryPath, registry);

          let fileCount = "unknown";
          let size = "unknown";
          try {
            fileCount = getRepoFileCount(repoPath);
            size = await getRepoSize(ctx, repoPath);
          } catch {
            // Ignore stat errors.
          }

          return `Added '${name}' (${scope})
  URL: ${url}
  Branch: ${branch}
  Notes: ${notes || "(none)"}
  Files: ${fileCount}
  Size: ${size}`;
        }

        case "remove": {
          if (!name) {
            return "Error: 'remove' requires a name.\nUsage: remove <name>";
          }

          const resource = findResource(paths, name);
          if (!resource) {
            return `Error: Resource '${name}' not found.`;
          }

          const registryPath = getRegistryPathForScope(paths, resource.scope);
          const repoPath = getResourcePath(paths, resource);

          if (fs.existsSync(repoPath)) {
            fs.rmSync(repoPath, { recursive: true });
          }

          const registry = loadRegistry(registryPath);
          registry.resources = registry.resources.filter((item) => item.name !== name);
          saveRegistry(registryPath, registry);

          return `Removed '${name}'`;
        }

        case "list": {
          const resources = getMergedResources(paths);
          if (resources.length === 0) {
            return "No resources found.\n\nAdd one with: /resource add <name> <url> [branch] [notes]";
          }

          let output = "Library Resources:\n";
          for (const resource of resources) {
            const repoPath = getResourcePath(paths, resource);
            const exists = fs.existsSync(repoPath);
            const status = exists ? "" : " [NOT CLONED]";
            output += `\n${resource.name} [${resource.scope}]${status}`;
            output += `\n  ${resource.url} (${resource.branch})`;
            if (resource.notes) {
              output += `\n  Notes: ${resource.notes}`;
            }
            output += `\n  Updated: ${resource.updatedAt}`;
          }
          return output;
        }

        case "update": {
          const resources = getSelectedResources(paths, name);

          if (resources.length === 0) {
            return name
              ? `Error: Resource '${name}' not found.`
              : "No resources to update.";
          }

          const results: string[] = [];
          for (const resource of resources) {
            const repoPath = getResourcePath(paths, resource);

            if (!fs.existsSync(repoPath)) {
              results.push(`${resource.name}: Not cloned (use 'restore' to clone)`);
              continue;
            }

            try {
              const pullResult = await ctx.$`git -C ${repoPath} pull`.quiet();

              if (pullResult.exitCode === 0) {
                updateResourceTimestamp(paths, resource);
                const output = String(pullResult.stdout).trim();
                results.push(`${resource.name}: ${output || "Already up to date"}`);
              } else {
                results.push(`${resource.name}: Error - ${pullResult.stderr}`);
              }
            } catch (error) {
              results.push(`${resource.name}: Error - ${getErrorMessage(error)}`);
            }
          }
          return results.join("\n");
        }

        case "info": {
          if (!name) {
            return "Error: 'info' requires a name.\nUsage: info <name>";
          }

          const resource = findResource(paths, name);
          if (!resource) {
            return `Error: Resource '${name}' not found.`;
          }

          const repoPath = getResourcePath(paths, resource);
          const exists = fs.existsSync(repoPath);

          let info = `Resource: ${resource.name}
Scope: ${resource.scope}
URL: ${resource.url}
Branch: ${resource.branch}
Notes: ${resource.notes || "(none)"}
Path: ${repoPath}
Cloned: ${resource.clonedAt}
Updated: ${resource.updatedAt}
Status: ${exists ? "Cloned" : "NOT CLONED"}`;

          if (exists) {
            try {
              const size = await getRepoSize(ctx, repoPath);
              const fileCount = getRepoFileCount(repoPath);
              const lastCommit = (
                await ctx.$`git -C ${repoPath} log -1 --format="%h %s (%cr)"`.text()
              ).trim();

              info += `\nSize: ${size}`;
              info += `\nFiles: ${fileCount}`;
              info += `\nLast Commit: ${lastCommit}`;
            } catch {
              // Ignore stat errors.
            }
          }

          return info;
        }

        case "restore": {
          const resources = getSelectedResources(paths, name);

          if (resources.length === 0) {
            return name
              ? `Error: Resource '${name}' not found in registry.`
              : "No resources in registry to restore.";
          }

          const results: string[] = [];
          for (const resource of resources) {
            const repoPath = getResourcePath(paths, resource);

            if (fs.existsSync(repoPath)) {
              results.push(`${resource.name}: Already cloned`);
              continue;
            }

            const reposDir = getReposDirForScope(paths, resource.scope);
            ensureDir(reposDir);

            try {
              const cloneResult = await ctx.$`git clone --branch ${resource.branch} ${resource.url} ${repoPath}`.quiet();

              if (cloneResult.exitCode === 0) {
                updateResourceTimestamp(paths, resource);
                results.push(`${resource.name}: Restored`);
              } else {
                results.push(`${resource.name}: Error - ${cloneResult.stderr}`);
              }
            } catch (error) {
              results.push(`${resource.name}: Error - ${getErrorMessage(error)}`);
            }
          }
          return results.join("\n");
        }

        default:
          return `Unknown action: ${action}. Valid actions: add, remove, list, update, info, restore`;
      }
    },
  });
};
