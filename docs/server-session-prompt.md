You're picking up Matinee on my server, which runs Jellyfin, Seerr and the arr stack and is on the same network as the TV. Read CLAUDE.md, CONTEXT.md, README.md and docs/adr/ first, and use the glossary's terms.

Where things stand: a cloud session already did step 4 of the original plan on branch `claude/matinee-roku-setup-5qi3r7`. The code is now BrighterScript (`.bs`), `scripts/deploy.sh` compiles it with `bsc` and stops on errors, and ADR 0003 is accepted. That build has **not** been on the TV yet. Steps 1 to 3 were blocked because the cloud couldn't reach the TV or Jellyfin.

Setup check before starting: we should be on that branch, `.env` should exist (copied from `.env.example` and filled in), and `npm ci` should have been run. If Node.js or `nc` is missing, tell me. Don't install anything system-wide without asking.

Work in this order, and check in with me after each step:
1. **Confirm the loop works.** Run `scripts/deploy.sh` to compile and install the BrighterScript build, and `scripts/logs.sh` (in the background) to watch the debug log. Tell me if either fails, or if the log shows a crash at startup. Then ask me to check that the app opens and Home, Settings and playback look and work as before. This is the first install of the compiled code, so I need to check it myself on the TV.
2. **Trailer Preview isn't playing.** Use the Jellyfin API (`X-Emby-Token: $JELLYFIN_API_KEY`) to check whether my movies actually have local trailers, for example `/Items/{id}/LocalTrailers` for a sample of titles. Report how many have them. If none do, tell me and help me set up Trailarr in my arr stack. If some do, name one for me to focus on the TV, read the `[Matinee] trailer:` log lines, and fix the cause in `components/util/TrailerHost.bs`.
3. **Check the Card focus look (v2.3).** Ask me for a photo of the TV with a Card Focused, and adjust it if anything looks off.
4. **Release.** Once steps 1 to 3 work, bump `minor_version`/`build_version` in `manifest` to v2.4, update README's "What's new", tag `v2.4`, and attach `dist/matinee.zip` to a GitHub release.

Also noted: the Up Next Prompt in `components/screens/PlayerScreen.bs` and `makeAvatar` in `components/util/Api.bs` use a few hard-coded colors instead of Theme tokens. Fix that only if you're already in those files.

Rules: commit and push after each working step, on branch `claude/matinee-roku-setup-5qi3r7`. Never print or commit secrets from `.env`. Anything visual needs my eyes on the TV, so ask me rather than assuming it looks right.
