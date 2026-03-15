import * as fs from "fs";
import * as path from "path";

const normalizePathForGlob = (value: string): string => {
  return value.split(path.sep).join("/");
};

const patternHasPathSeparator = (pattern: string): boolean => {
  return normalizePathForGlob(pattern).includes("/");
};

export const matchesFullGlob = (
  relativeFilePath: string,
  pattern: string,
): boolean => {
  const normalizedPath = normalizePathForGlob(relativeFilePath);
  const normalizedPattern = normalizePathForGlob(pattern);

  if (path.matchesGlob(normalizedPath, normalizedPattern)) {
    return true;
  }

  if (patternHasPathSeparator(normalizedPattern)) {
    return false;
  }

  return path.matchesGlob(
    path.posix.basename(normalizedPath),
    normalizedPattern,
  );
};

export const listRelativeFiles = (
  rootPath: string,
  excludedDirs: ReadonlySet<string>,
  currentRelativePath = "",
): string[] => {
  const currentPath = currentRelativePath
    ? path.join(rootPath, currentRelativePath)
    : rootPath;
  const entries = fs.readdirSync(currentPath, { withFileTypes: true });
  const files: string[] = [];

  for (const entry of entries) {
    if (excludedDirs.has(entry.name)) {
      continue;
    }

    const relativePath = currentRelativePath
      ? path.join(currentRelativePath, entry.name)
      : entry.name;

    if (entry.isDirectory()) {
      files.push(...listRelativeFiles(rootPath, excludedDirs, relativePath));
      continue;
    }

    if (entry.isFile()) {
      files.push(normalizePathForGlob(relativePath));
    }
  }

  return files;
};
