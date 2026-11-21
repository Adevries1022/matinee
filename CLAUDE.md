# Matinee

A Roku app (SceneGraph + BrighterScript, compiled to BrightScript) for Jellyfin, with Seerr requests. It's tested on a TCL 55R655 Roku TV ("Living Room"), but it's meant for other households' Roku TVs too, including entry-level ones, so keep motion and image sizes light.

## Read first
- `CONTEXT.md`: the glossary. Use its terms (Card, Focused, Hero, Row, Theme, Layout Add-on, Trailer Preview, etc.) in code, comments and conversation.
- `docs/adr/`: decisions already made, including ADR 0003 (BrighterScript).
- `README.md`: features and remote controls.

## Working loop
- Source is BrighterScript (`.bs`). XML `<script>` tags point at the `.bs` file; `bsc` compiles each to `.brs` and rewrites the URI in the package. Never add `.brs` source files.
- Run `npm install` once after cloning (Node.js 20.12 or newer). Everything runs through npm, so it works on Windows without bash, zip or nc.
- `npm run build` compiles and lints (bslint runs as a `bsc` plugin, rules in `bslint.json`) and writes `dist/matinee.zip`. It fails on any compiler or lint error. `npm run lint` checks without packaging.
- `npm run deploy` builds, then sideloads `dist/matinee.zip` onto the Roku with roku-deploy (Developer Mode must stay on). Ask the user before deploying: others may be watching the TV.
- `npm run logs` streams the Roku debug log (port 8085). Matinee prints lines starting with `[Matinee]`.
- Keep the build free of warnings. For an unused callback parameter, prefix it with `_` (e.g. `_event`) rather than disabling the rule.
- `.env` holds the Roku IP and dev password, the Jellyfin URL and API key, and the Seerr URL. Never commit it or print secrets.
- Query Jellyfin directly (with `X-Emby-Token: $JELLYFIN_API_KEY`) to check facts, such as whether a title has local trailers, instead of guessing.
- After each change: deploy, watch the logs, and ask the user to check the TV for anything visual.

## Conventions
- Saved data lives in the registry section "Marquee" (the old working name) so existing sign-ins keep working. Don't rename it.
- Every color, size and shape comes from the Theme tokens in `components/util/Api.bs` (`th()`). No hard-coded colors in screens.
- Network calls go through `apiRequest` / `seerrRequest` (render thread) and `ApiTask` (task thread). Never use roUrlTransfer on the render thread.
- Avoid BrightScript reserved words as variable names (pos, type, step, next, stop, box, dim, run, tab), and don't name a local or parameter after a function in scope (the compiler rejects it).
- Update `CONTEXT.md` when a term changes, and add an ADR only for hard-to-reverse, surprising trade-offs.

## Git and releases
- The repo lives on GitHub (private for now, GPL-3.0). Commit each working change with a clear message and push.
- Bump `minor_version`/`build_version` in `manifest` for each release, tag it (`v2.4`), and attach `dist/matinee.zip` to a GitHub release so the install zip always matches a tag.
