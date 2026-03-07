interface ErrorWithCode {
  code?: unknown;
}

const isErrorWithCode = (value: unknown): value is ErrorWithCode => {
  return typeof value === "object" && value !== null;
};

export const getErrorMessage = (error: unknown): string => {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
};

export const isCommandMissing = (error: unknown): boolean => {
  if (!isErrorWithCode(error)) {
    return false;
  }
  return error.code === "ENOENT";
};
