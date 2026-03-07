export type ResourceScope = "global" | "project";

export interface Resource {
  name: string;
  url: string;
  branch: string;
  notes: string;
  scope: ResourceScope;
  clonedAt: string;
  updatedAt: string;
}

export interface ResourceRegistry {
  version: number;
  resources: Resource[];
}
