import { tool } from "@opencode-ai/plugin";
import * as fs from "fs";
import * as path from "path";

import type { ResourcePaths } from "./paths";
import { getResourcePath } from "./paths";
import { findResource } from "./registry";

interface CreateReadToolOptions {
  paths: ResourcePaths;
}

export const createResourceReadTool = ({ paths }: CreateReadToolOptions) => {
  return tool({
    description: "Read a specific file from a library resource",
    args: {
      name: tool.schema.string().describe("Resource name"),
      filePath: tool.schema
        .string()
        .describe("Path to file within the resource (relative to repo root)"),
    },
    async execute(args) {
      const { name, filePath } = args;

      const resource = findResource(paths, name);
      if (!resource) {
        return `Resource '${name}' not found.`;
      }

      const repoPath = getResourcePath(paths, resource);
      if (!fs.existsSync(repoPath)) {
        return `Resource '${name}' is not cloned. Run '/resource restore ${name}' first.`;
      }

      const fullPath = path.join(repoPath, filePath);
      if (!fs.existsSync(fullPath)) {
        return `File not found: ${filePath}\n\nUse resource_tree to see available files.`;
      }

      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        return `'${filePath}' is a directory. Use resource_tree to list its contents.`;
      }

      const content = fs.readFileSync(fullPath, "utf-8");
      return `# ${name}/${filePath}\n\n${content}`;
    },
  });
};
