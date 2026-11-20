# Matinee

A Roku app (SceneGraph + BrightScript) for Jellyfin, with Seerr requests. It runs on a TCL 4-Series 55S435 (2021), an entry-level Roku TV, so keep motion and image sizes light.

## Read first
- `CONTEXT.md`: the glossary. Use its terms (Card, Focused, Hero, Row, Theme, Layout Add-on, Trailer Preview, etc.) in code, comments and conversation.
- `docs/adr/`: decisions already made. ADR 0003 (BrighterScript) is deferred until package installs are available; this server can install them.
- `README.md`: features and remote controls.

## Working loop
- `scripts/deploy.sh` builds `dist/matinee.zip` and sideloads it onto the Roku (Developer Mode must stay on).
- `scripts/logs.sh` streams the Roku debug log. Matinee prints lines starting with `[Matinee]`.
- `.env` holds the Roku IP and dev password, the Jellyfin URL and API key, and the Seerr URL. Never commit it or print secrets.
- Query Jellyfin directly (with `X-Emby-Token: $JELLYFIN_API_KEY`) to check facts, such as whether a title has local trailers, instead of guessing.
- After each change: deploy, watch the logs, and ask the user to check the TV for anything visual.

## Conventions
- Saved data lives in the registry section "Marquee" (the old working name) so existing sign-ins keep working. Don't rename it.
- Every color, size and shape comes from the Theme tokens in `components/util/Api.brs` (`th()`). No hard-coded colors in screens.
- Network calls go through `apiRequest` / `seerrRequest` (render thread) and `ApiTask` (task thread). Never use roUrlTransfer on the render thread.
- Avoid BrightScript reserved words as variable names (pos, type, step, next, stop, box, dim, run, tab).
- Update `CONTEXT.md` when a term changes, and add an ADR only for hard-to-reverse, surprising trade-offs.
