import * as os from "os";
import * as path from "path";

import type { Resource, ResourceScope } from "./types";

export interface ResourcePaths {
  globalResourcesDir: string;
  globalReposDir: string;
  globalRegistry: string;
  projectResourcesDir: string;
  projectReposDir: string;
  projectRegistry: string;
}

const GLOBAL_RESOURCES_DIR = path.join(os.homedir(), ".config/opencode/resources");
const GLOBAL_REPOS_DIR = path.join(GLOBAL_RESOURCES_DIR, "repos");
const GLOBAL_REGISTRY = path.join(GLOBAL_RESOURCES_DIR, "resources.json");

export const createResourcePaths = (directory: string): ResourcePaths => {
  const projectResourcesDir = path.join(directory, ".opencode/resources");
  return {
    globalResourcesDir: GLOBAL_RESOURCES_DIR,
    globalReposDir: GLOBAL_REPOS_DIR,
    globalRegistry: GLOBAL_REGISTRY,
    projectResourcesDir,
    projectReposDir: path.join(projectResourcesDir, "repos"),
    projectRegistry: path.join(projectResourcesDir, "resources.json"),
  };
};

export const getReposDirForScope = (
  paths: ResourcePaths,
  scope: ResourceScope
): string => {
  return scope === "project" ? paths.projectReposDir : paths.globalReposDir;
};

export const getRegistryPathForScope = (
  paths: ResourcePaths,
  scope: ResourceScope
): string => {
  return scope === "project" ? paths.projectRegistry : paths.globalRegistry;
};

export const getResourcePath = (
  paths: ResourcePaths,
  resource: Resource
): string => {
  return path.join(getReposDirForScope(paths, resource.scope), resource.name);
};
