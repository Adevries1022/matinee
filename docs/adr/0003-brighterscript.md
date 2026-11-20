---
status: accepted
---

# Write Marquee in BrighterScript

Marquee's code should be written in BrighterScript and compiled to plain BrightScript before installing. That way errors are caught before anything reaches the TV, which matters because each change can only be tested by sideloading. The cost is a build step and a Node.js toolchain: the app could no longer be zipped straight from the source folder.

**History:** v2.1 to v2.3 were built in plain BrightScript because package installs were turned off in the build environment, with a custom static checker standing in. Adopted once package installs were allowed.

## Consequences

- Source files are `.bs`; XML `<script>` tags point at the `.bs` file and the compiler rewrites them to `.brs`. The package is zipped from `build/`, never from the source folder.
- `scripts/deploy.sh` runs `bsc` (BrighterScript plus the bslint plugin) first, and stops if it reports an error. `scripts/deploy.sh --build-only` builds without installing.
- `brighterscript` and `@rokucommunity/bslint` are pinned to exact versions in `package.json`.
- The compiled package includes BrighterScript's small runtime helper, `source/bslib.brs`.
