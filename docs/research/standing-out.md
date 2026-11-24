# How Matinee stands out

November 2026. The question: Matinee has Seerr built into a Roku client, but so does Moonfin. How does Matinee become the best Roku client for Jellyfin, on the features people care about and on design?

**Sources.** Moonfin's [Features](https://github.com/Moonfin-Client/Roku/wiki/Features) and [User Guide](https://github.com/Moonfin-Client/Roku/wiki/User-Guide) wikis and releases; [Starfin](https://github.com/thedavidhoffman/starfin-roku)'s README and releases; [JellyWatch](https://jellywatch.app/doc/player/tv-requests)'s request docs; issue counts, comments and reactions on [jellyfin-roku](https://github.com/jellyfin/jellyfin-roku/issues) and [Moonfin](https://github.com/Moonfin-Client/Roku/issues); the Jellyfin forum; a few 2026 reviews. **Reddit is missing**: it refuses automated readers, and the built-in browser blocks it. Upvote-weighted Reddit evidence would sharpen the "what users want" ranking.

## The field

| | Official Jellyfin | Moonfin | Starfin | Matinee |
|---|---|---|---|---|
| In the Roku store | Yes | Yes | Yes (since about Sept 2026) | Not yet |
| Built | Original | Fork of the official app, about 7,000 commits, 105 stars | From scratch with Codex, 3,000+ unit tests | From scratch |
| Seerr | No | Yes, **through its own server plugin** (Seerr's address is set on the server) | No | Yes, **no plugin**: finds Seerr on its own |
| Radarr and Sonarr | No | Through its Moonbase plugin (calendar, stuck-download reasons) | No | Directly: Activity, queue, removing downloads |
| Breadth | Movies, TV, music, Live TV, photos | Everything: music, Live TV, watch parties, chat, calendar, achievements, Plex and Emby | Movies, TV, music, playlists, Live TV | Movies and TV only |
| Customization | Little | Huge: 6 Home banner styles, 9 Details layouts, a row editor, theme store | Many library layouts | Six Themes and accents, on purpose |

**What this means.** Moonfin wins on breadth and won't be out-featured quickly. Its weak spots are what breadth costs:
- **It needs a server plugin** for Seerr. Setup failures ("Plugin proxy request failed", "stuck on Loading") are among its busiest Seerr issues ([#75](https://github.com/Moonfin-Client/Roku/issues/75), [#72](https://github.com/Moonfin-Client/Roku/issues/72)).
- **It's complex,** with nine Details layouts and hundreds of settings.
- **It's heavy:** "Roku Ultra freezes when navigating to libraries" ([#254](https://github.com/Moonfin-Client/Roku/issues/254)), and reviews say it lags on older Rokus.

Matinee wins by being the one that **just works, looks the best and stays fast**, with **the best requests on a TV**, while closing the gaps people actually notice.

## What users complain about most

Across every Roku client, the top complaints are about **playback, not looks** (counts are jellyfin-roku issues with the word in the title):
1. **Audio** (31 issues): AAC 5.1 won't direct play ([#912](https://github.com/jellyfin/jellyfin-roku/issues/912), 40 comments), DTS plays silent, EAC3 fails. Roku can't decode AAC or Opus above stereo.
2. **Seeking during a transcode** hangs or fails ([#582](https://github.com/jellyfin/jellyfin-roku/issues/582), 48 comments, the busiest open issue).
3. **Subtitles** (18 issues, including the top-voted one): SRT only works with remuxing off ([#537](https://github.com/jellyfin/jellyfin-roku/issues/537)), ASS shows one track, forced tracks don't show.
4. **Crashes and freezes** (24 issues).
5. **Live TV** (26 issues).
6. **4K, HDR and Dolby Vision** failing to play.

**Matinee's own risk here:** its playback profile (`deviceProfile()` in PlayerScreen.bs) checks which codecs the Roku can decode, but sets **no limits**: no AAC channel limit, no 10-bit H.264 rule (Rokus can't play it), no AV1, no level or resolution caps. Files that hit those cases will try to direct play and fail or play silent, exactly the top complaints above.

## What users ask for

Evidence is thinner (small reaction counts), ranked by how often it comes up:
1. **Home and library customization**: genre, collection, network and studio rows; sort and filter like the web app ([Moonfin #124](https://github.com/Moonfin-Client/Roku/issues/124), [jellyfin-roku #19](https://github.com/jellyfin/jellyfin-roku/issues/19)).
2. **Music** that works (21 issues, mostly bugs).
3. **Skip intro and credits, automatically if wanted.** This is now expected, not special: the official app has an auto-skip option.
4. **Faster scrubbing** (15x, 50x) with thumbnails ([#14](https://github.com/jellyfin/jellyfin-roku/issues/14)).
5. **Small playback touches**: "ends at" time ([#926](https://github.com/jellyfin/jellyfin-roku/issues/926)), Go to series, playback speed.
6. **SyncPlay** and **profile PINs**: low but recurring.

**Requests on a TV.** The official apps have none, and there's a [feature-board request](https://features.jellyfin.org/posts/4182) for it. People want Seerr pages that match the app's look, trailers on titles they could request ([Moonfin #358](https://github.com/Moonfin-Client/Roku/issues/358)), network and studio rows, and a reliable setup. **Nobody tells you on the TV when your request is ready:** JellyWatch only notifies phones, and Moonfin doesn't notify at all.

## Where Matinee is today

**Ahead or equal:**
- **Seerr with no plugin** and automatic discovery.
- **Requests from Search.**
- **My requests** with download progress.
- **Radarr and Sonarr** without a plugin.
- **A cinematic Home** with Trailer Preview.
- **Title Options**, including Remove from Continue watching.
- **Skip intro** and the Up next countdown at the credits.
- **Trickplay thumbnails** when the server has them. [features.md](../features.md) wrongly says it has none.
- **Subtitle search.**
- **Light enough for entry-level TVs.**

**Behind Moonfin, in ways people notice:**
- **Home:** Seerr rows on Home.
- **Requests:**
  - A one-sheet request with HD/4K, seasons and remaining quota.
  - Approve and decline for admins.
  - Report an issue.
  - Requesting from a collection.
  - Stuck-download reasons.
- **Player:**
  - Auto-skip as a setting.
  - Still watching?
  - Faster scrubbing.
  - Subtitle offset.
- **Library:** collections, and Home row choice.
- **Breadth:** music and Live TV.

## The plan, ranked

Sizes: S is a day or less, M a few days, L a week or more.

### 1. Playback that just works (the top complaints everywhere)
| # | What | Why | Size |
|---|---|---|---|
| 1 | **Codec limits in the device profile**: AAC and Opus to 2 channels; no 10-bit H.264 or AV1 direct play unless the Roku says it can; HEVC and H.264 level and resolution caps from `CanDecodeVideo`; DTS and TrueHD transcoded to AC3 or passed through when the TV or receiver supports it | Stops silent audio and failed starts, the number one complaint on every Roku client | M |
| 2 | **A test library** of short sample files: AAC 5.1, EAC3, DTS, 10-bit H.264, HEVC HDR, AV1, SRT, ASS with two tracks, forced subtitles, PGS. A script plays each and reads the log | Proves it works and catches regressions; no other client shows this | M |
| 3 | **Seeking during a transcode**: confirm Matinee's restart-at-position works deep into long transcoded files, and on 4K | The busiest open issue on the official app | S |
| 4 | **Subtitles**: two ASS tracks, forced-only tracks, SRT inside MKV | The top-voted issue on the official app | S–M |

### 2. The best requests on a TV (the reason to choose Matinee)
| # | What | Why | Size |
|---|---|---|---|
| 5 | **"Ready to watch"**: when one of your requests arrives, a Toast on whatever screen you're on, and a **Ready to watch** Row at the top of Home until you've played it | No client tells you on the TV. Matinee already checks every minute for My requests | S–M |
| 6 | **Seerr Rows on Home** (Trending, Coming soon), off by default, with Request right from the Card's Title Options | Requests where people already are | M |
| 7 | **One request sheet**: seasons, HD or 4K, your remaining quota and, for admins, quality profile and folder | Moonfin has it; Matinee spreads it over buttons and pills | M |
| 8 | **Approve and decline on the TV** for admins, from My requests, with a count on the Rail | The household admin is often the one watching | S–M |
| 9 | **Report a problem** on a title (video, audio, subtitles, other), into Seerr's issues | Closes the loop with whoever runs the server | S |
| 10 | **Why it's stuck**: show Radarr or Sonarr's reason (stalled, failed, waiting for import) on My requests and Activity | Matinee already talks to both directly | S |
| 11 | **Trailers on Request Details** | Wanted on Moonfin. Seerr's trailers are YouTube links, which Roku can't play, so this needs a trailer source Roku can use. Check before promising | ? |

### 3. Expected touches (cheap, and people notice when they're missing)
| # | What | Size |
|---|---|---|
| 12 | **Skip intro automatically**, as a setting per person (never on the last episode in a row) | S |
| 13 | **Still watching?** after three episodes with no key press | S |
| 14 | **"Ends at 10:42"** on the seek bar and Details | S |
| 15 | **Faster scrubbing**: hold Rewind or Fast-forward to speed up to 15x and 60x, with thumbnails | S–M |
| 16 | **Collections**: a Collections Row and a collection page | M |
| 17 | **Choose your Home Rows**: show, hide and reorder from Settings (a short list, not Moonfin's editor) | M |
| 18 | **Subtitle offset** for out-of-sync subtitles | S |

### 4. Reach (people can't pick what they can't install)
| # | What | Size |
|---|---|---|
| 19 | **The Roku Channel Store** ([roku-store.md](../roku-store.md)): the voice keyboard, Instant Replay, captions, deep link tests | M |
| 20 | **README screenshots** from the public demo server | S |
| 21 | **A cheap Roku to test on** (Roku Express, about $30): Roku certifies on slow devices, and "fast on cheap Rokus" should be measured, not claimed | — |

### 5. Breadth: later, on purpose
- **Music** and **Live TV** are real gaps for some households, but each is a large build and a large bug surface (both are among the official app's buggiest areas). Do them after 1 to 3, and only as well as the rest of Matinee.
- **Leave out**: watch parties, chat, achievements, Plex and Emby, a theme store, Details layout choices. They are Moonfin's lane, and they cost the simplicity that sets Matinee apart.

## What to say about Matinee
- **Requests on your TV with nothing to install on your server.** Matinee finds Seerr by itself, and tells you when what you asked for is ready.
- **Plays your files the first time.** Tested against a library of tricky formats.
- **Looks like a streaming service, and stays fast on a $30 Roku.**

## To add Reddit
Reddit can't be read by Claude's tools. Paste the top threads, or turn on Claude in Chrome, to weigh these wants by upvotes. Searches that matter: "best jellyfin client roku" in r/jellyfin and r/selfhosted; the Moonfin and Starfin announcement threads and their comments; "jellyseerr roku" or "requests on tv" in r/jellyfin and r/Overseerr.
