# Matinee: a Jellyfin app for Roku (v2.3)

## Install or update (sideload)
1. **Turn on Developer Mode on the Roku** (first time only). On the remote, press Home 3 times, Up 2 times, then Right, Left, Right, Left, Right. Accept the terms, set a password, and let the Roku restart. Write down the IP address it shows.
2. On a computer on the same network, open `http://<roku-ip>` in a browser. Sign in with the username `rokudev` and your password.
3. Click **Upload**, choose `matinee-v2.3.zip`, then click **Install with zip** (or **Replace**). Your server and sign-ins are kept.
4. If Matinee asks, pick your server, then pick your name on **Who's watching?**. Approve the code it shows: in Jellyfin on your phone, go to your profile → **Quick Connect** and enter it. You can also press OK to use your password.

Needs Jellyfin 10.9 or newer. Requests need Seerr.

## Remote controls
| Where | Button | What it does |
|---|---|---|
| Any browse screen | Left (Side Rail) or Up (Top Bar) | Opens the main menu |
| Main menu | Right or Back | Closes the menu |
| Home rows | OK on **Continue Watching** or **Next Up** | Plays right away, picking up where you left off |
| Home rows | OK on anything else | Opens details |
| Any row | * (options) | Opens details for the selected title |
| Lower rows | Back | Jumps back to the first row |
| Show details | Down | Goes to seasons, then episodes |
| Any row (after a few seconds) | Play | Turns the Trailer Preview's sound on or off |
| Search | Right / Left | Moves between the keyboard and the results grid |
| Playing | * (options) | Opens the Track Picker for audio and subtitles |
| Near the end of an episode | OK / Back | Plays the next episode now / keeps watching |
| Settings | OK | Opens a setting's options; Up/Down previews each one live, OK keeps it, Back cancels |
| Who's watching? | * (options) | Change server |

## What's new in v2.3
- **Cleaner Focused Cards:** each Card grows from its centre inside its own space, with a single ring just outside its edge. No more double border or clipped edges.
- **Bigger menu:** larger Side Rail icons and labels.
- **Trailer Preview:** works with servers older than 10.9 too, and writes what it's doing to the Roku debug log (`telnet <roku-ip> 8085`) so missing trailers are easy to diagnose.

## What's new in v2.2
- **New name:** Marquee is now **Matinee**. The Marquee Classic Theme is now called **Amber**. Your sign-ins and settings carry over.
- **Trailer Preview:** stay on a title for about 3 seconds and its trailer fades in behind the title, muted. Press Play for sound. Works on Home, in libraries and on details pages. It uses trailer files stored on your server; **Trailarr** (an arr-stack app) can download them for your whole library. Reduce Motion turns it off.
- **Search is a grid again:** your library first, then **Not in your library** for titles you can request, with an **Info Line** naming whatever you're on.
- **Redesigned Settings:** two tiles, Appearance and Connections. Each setting opens a short list of options that previews live, and Themes show as picture cards.
- **Fixed:** Focused Cards no longer get their tops cut off.

## What's new in v2.1
- **Themes:** Midnight Glass (the default: black, rounded and frosted), Void (pure black, flat and sharp) and Amber (the original look). Each has its own Accent, which you can change.
- **Layout Add-ons** that mix with any Theme: **Big Hero** (taller artwork, less text) and **Mini Cards** (more titles on screen).
- **Menu style:** a Side Rail down the left edge, or the Top Bar.
- **Settings**, with a live preview. **Appearance** is set separately for each person. **Connections** applies to the whole TV, and only Jellyfin administrators can change it.
- **Track Picker** during playback. It follows each person's Jellyfin audio and subtitle preferences, and your choice carries on to the next episode. Picture-based subtitles (like PGS) are burned in by the server.
- **Requests through Seerr:** Matinee finds Seerr on its own (port 5055 on the Jellyfin machine). Each person signs in once with Quick Connect. You get a **Discover** page, plus a **Not in your library** row in Search with status badges (Requested, Downloading, Partly available). Shows can be requested in full or season by season.
- **Smoother on lower-end TVs:** artwork loads at the size it's shown and fades in, the next row loads ahead, and there's a **Reduce Motion** setting.

## Earlier
- v1.1: finds your server automatically, Who's watching?, Quick Connect sign-in, Switch User.
- v1: the first version, with a Netflix-style home screen, search, details, playback and Up Next.

## Not yet
Music, Live TV, Collections rows.

## Files
- `components/screens/`: the screens
- `components/MainMenu.*`: the Side Rail and Top Bar
- `components/CardItem.*`: the poster and thumbnail card
- `components/util/Api.bs`: Theme tokens, Jellyfin and Seerr requests, shared drawing helpers
- `CONTEXT.md` and `docs/adr/`: the project glossary and design decisions

## Building from source
Matinee is written in [BrighterScript](https://github.com/rokucommunity/brighterscript) (`.bs` files) and compiled to plain BrightScript before it goes on the TV. You need Node.js 20.12 or newer; it works the same on Windows, macOS and Linux.

1. `npm install`
2. Copy `.env.example` to `.env` and fill in your Roku's IP address and developer password (plus the Jellyfin and Seerr details if you use them). `.env` is never committed.
3. Use these commands:

| Command | What it does |
|---|---|
| `npm run build` | Compiles and lints, then writes `dist/matinee.zip`. Stops on any error. |
| `npm run lint` | Compiles and lints without making the zip. |
| `npm run deploy` | Builds, then installs the zip on the Roku. |
| `npm run logs` | Streams the Roku's debug log. Ctrl+C to stop. |
