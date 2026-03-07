import { type Plugin } from "@opencode-ai/plugin";

import { createResourceManageTool } from "../lib/library-resources/manage";
import { createResourcePaths } from "../lib/library-resources/paths";
import { createResourceReadTool } from "../lib/library-resources/read";
import { createResourceSearchTool } from "../lib/library-resources/search";
import { createResourceTreeTool } from "../lib/library-resources/tree";

export const LibraryResourcesPlugin: Plugin = async (ctx) => {
  const paths = createResourcePaths(ctx.directory);

  return {
    tool: {
      resource_manage: createResourceManageTool({ ctx, paths }),
      resource_search: createResourceSearchTool({ paths }),
      resource_read: createResourceReadTool({ paths }),
      resource_tree: createResourceTreeTool({ paths }),
    },
  };
};
