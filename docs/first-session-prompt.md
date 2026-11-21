# First message for Claude Code on the server

Paste this after running `claude` in the project folder:

---

You're picking up Matinee, a Roku app for my Jellyfin server. Read CLAUDE.md, CONTEXT.md, README.md and docs/adr/ before doing anything, and use the glossary's terms.

My setup: Jellyfin, Seerr and the arr stack run on this server. The TV is a TCL 4-Series 55S435 Roku TV with Developer Mode on. `.env` has the Roku IP and dev password, the Jellyfin URL and an API key, and the Seerr URL.

Work in this order, and check in with me after each step:

1. **Confirm the loop works.** Run `npm install`, then `npm run deploy` to install the current build on the TV and `npm run logs` to watch the debug log. Tell me if either fails.
2. **Trailer Preview isn't playing.** Use the Jellyfin API to check whether my movies actually have local trailers, for example `/Items/{id}/LocalTrailers` for a few titles. If none do, tell me and help me set up Trailarr in my arr stack. If some do, focus one on the TV, read the `[Matinee] trailer:` log lines, and fix the cause.
3. **Check the new Card focus look** (v2.3): ask me for a photo of the TV and adjust it if anything looks off.
4. **Switch to BrighterScript** as described in ADR 0003: set up the toolchain, convert the code, add a lint/build step to `scripts/deploy.sh`, and mark the ADR accepted.

Rules: commit and push after each working step. Never print or commit secrets from `.env`. Anything visual needs my eyes on the TV, so ask me rather than assuming it looks right.
