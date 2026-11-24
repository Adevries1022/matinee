# Developing Matinee

For people who want to change Matinee or build it themselves. To just install it, see the [README](../README.md).

## Files
- `components/screens/`: the screens
- `components/MainScene.*`: start-up, the screen stack and saved sign-ins
- `components/MainMenu.*`: the Rail
- `components/CardItem.*`: the Cards
- `components/util/Api.bs`: Theme tokens, requests to each service, shared drawing helpers
- `components/util/Ui.bs`: buttons, pills, fields and the rest of the component kit
- `fonts/`: Inter and Space Grotesk, under the SIL Open Font License (included)
- `images/`: icons and shapes, mostly drawn by `scripts/make-images.mjs`
- `CONTEXT.md` and `docs/adr/`: the project glossary and design decisions

## Building from source
Matinee is written in [BrighterScript](https://github.com/rokucommunity/brighterscript) (`.bs` files) and compiled to plain BrightScript before it goes on the TV. You need Node.js 20.12 or newer; it works the same on Windows, macOS and Linux.

1. `npm install`
2. Copy `.env.example` to `.env` and fill in your Roku's IP address and developer password. The Jellyfin, Seerr, Radarr and Sonarr entries are optional, for checking things from the computer; the app on the TV doesn't read them. `.env` is never committed.
3. Use these commands:

| Command | What it does |
|---|---|
| `npm run build` | Compiles and lints, then writes `dist/matinee.zip`. Stops on any error. |
| `npm run lint` | Compiles and lints without making the zip. |
| `npm run deploy` | Builds, then installs the zip on the Roku. |
| `npm run sideload` | Installs the zip that's already built. |
| `npm run logs` | Streams the Roku's debug log. Ctrl+C to stop. |
| `npm run images` | Redraws the icons and shapes in `images/`. |
| `npm run screenshot -- <name>` | Saves what Matinee shows to `screenshots/<name>.jpg`. Video isn't captured. |
| `npm run key -- Left Down OK` | Presses remote buttons. The TV needs Control by mobile apps → Network access set to Permissive. |

Before changing anything, read `CONTEXT.md` (the glossary) and `docs/adr/` (decisions already made). [docs/roku-store.md](roku-store.md) tracks the work toward the Roku Streaming Store.
