---
status: proposed (deferred)
---

# Write Marquee in BrighterScript

Marquee's code should be written in BrighterScript and compiled to plain BrightScript before installing. That way errors are caught before anything reaches the TV, which matters because each change can only be tested by sideloading. The cost is a build step and a Node.js toolchain: the app could no longer be zipped straight from the source folder.

**Deferred:** v2.1 was built in plain BrightScript because package installs were turned off in the build environment. A custom static checker (block balance, reserved words, missing callbacks and functions, unknown components, missing images) stands in for now. Adopt BrighterScript once package installs are allowed.
