import * as fs from "fs";
import * as path from "path";

import {
  getRegistryPathForScope,
  type ResourcePaths,
} from "./paths";
import type { Resource, ResourceRegistry, ResourceScope } from "./types";

const isRecord = (value: unknown): value is Record<string, unknown> => {
  return typeof value === "object" && value !== null;
};

const isScope = (value: unknown): value is ResourceScope => {
  return value === "global" || value === "project";
};

const isString = (value: unknown): value is string => {
  return typeof value === "string";
};

const isResource = (value: unknown): value is Resource => {
  if (!isRecord(value)) {
    return false;
  }
  return (
    isString(value.name) &&
    isString(value.url) &&
    isString(value.branch) &&
    isString(value.notes) &&
    isScope(value.scope) &&
    isString(value.clonedAt) &&
    isString(value.updatedAt)
  );
};

const parseRegistry = (value: unknown): ResourceRegistry => {
  if (!isRecord(value)) {
    return { version: 1, resources: [] };
  }

  const version = typeof value.version === "number" ? value.version : 1;
  const resourcesValue = Array.isArray(value.resources) ? value.resources : [];
  const resources = resourcesValue.filter(isResource);
  return { version, resources };
};

export const ensureDir = (dir: string) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

export const loadRegistry = (registryPath: string): ResourceRegistry => {
  if (!fs.existsSync(registryPath)) {
    return { version: 1, resources: [] };
  }

  try {
    const parsed = JSON.parse(fs.readFileSync(registryPath, "utf-8"));
    return parseRegistry(parsed);
  } catch {
    return { version: 1, resources: [] };
  }
};

export const saveRegistry = (registryPath: string, registry: ResourceRegistry) => {
  ensureDir(path.dirname(registryPath));
  fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2));
};

export const getMergedResources = (paths: ResourcePaths): Resource[] => {
  const globalRegistry = loadRegistry(paths.globalRegistry);
  const projectRegistry = loadRegistry(paths.projectRegistry);

  const merged = new Map<string, Resource>();
  for (const resource of globalRegistry.resources) {
    merged.set(resource.name, { ...resource, scope: "global" });
  }
  for (const resource of projectRegistry.resources) {
    merged.set(resource.name, { ...resource, scope: "project" });
  }
  return Array.from(merged.values());
};

export const findResource = (
  paths: ResourcePaths,
  name: string
): Resource | undefined => {
  return getMergedResources(paths).find((resource) => resource.name === name);
};

export const getSelectedResources = (
  paths: ResourcePaths,
  name?: string
): Resource[] => {
  if (!name) {
    return getMergedResources(paths);
  }

  const resource = findResource(paths, name);
  return resource ? [resource] : [];
};

export const updateResourceTimestamp = (
  paths: ResourcePaths,
  resource: Resource
) => {
  const registryPath = getRegistryPathForScope(paths, resource.scope);
  const registry = loadRegistry(registryPath);
  const found = registry.resources.find((item) => item.name === resource.name);
  if (!found) {
    return;
  }
  found.updatedAt = new Date().toISOString();
  saveRegistry(registryPath, registry);
};
