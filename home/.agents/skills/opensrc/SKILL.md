---
name: opensrc
description: Use dependency source code in the current working directory's `opensrc/` folder, and fetch additional source with `opensrc --modify=false` when package internals matter.
---

Use this skill when you need to understand how a dependency works internally, not just its public API or types.

## Source Code Reference

Dependency source code is available in the current working directory under `opensrc/`.

Check `opensrc/sources.json` for the list of available packages and versions.

Prefer reading local source in `opensrc/` before making assumptions about third-party behavior.

## When To Use

Use this skill when:
- debugging behavior that depends on library internals
- verifying undocumented or unclear package behavior
- tracing implementation details beyond type definitions or README docs
- comparing local code against a dependency's actual source

Do not use this skill when public docs or types are sufficient.

## Fetching Additional Source Code

When the needed package or repository is not already present, use the CLI from the current working directory and always pass `--modify=false`:

```bash
opensrc --modify=false <package>           # npm package (e.g. opensrc --modify=false zod)
opensrc --modify=false pypi:<package>      # Python package (e.g. opensrc --modify=false pypi:requests)
opensrc --modify=false crates:<package>    # Rust crate (e.g. opensrc --modify=false crates:serde)
opensrc --modify=false <owner>/<repo>      # GitHub repo (e.g. opensrc --modify=false vercel/ai)
```

## Workflow

1. Check `opensrc/sources.json` in the current working directory to see whether the dependency is already available.
2. If available, inspect the relevant files under the current working directory's `opensrc/`.
3. If not available and fetching is appropriate, run the appropriate `opensrc --modify=false ...` command from the current working directory.
4. Read the fetched source and ground conclusions in implementation details.
5. Cite the package, version, and file paths you relied on when relevant.
