---
status: accepted
---

# Write Marquee in BrighterScript

Marquee's code should be written in BrighterScript and compiled to plain BrightScript before installing. That way errors are caught before anything reaches the TV, which matters because each change can only be tested by sideloading. The cost is a build step and a Node.js toolchain: the app could no longer be zipped straight from the source folder.

**History:** v2.1 to v2.3 were built in plain BrightScript because package installs were turned off in the build environment, with a custom static checker standing in. That limit is gone, so the deferral is over.

## Consequences

- Source files are `.bs`. The XML `<script>` tags name the `.bs` file and `bsc` rewrites them to `.brs` in the package.
- `npm run build` compiles, lints with bslint (`bslint.json`) and writes `dist/matinee.zip`; any error stops it. `npm run deploy` sideloads that zip with roku-deploy, and `npm run logs` streams the debug log. These replace the bash scripts, so building needs only Node.js, on any OS.
- The tool versions (brighterscript, bslint, roku-deploy) are pinned exactly in `package.json`, so a build is repeatable.
