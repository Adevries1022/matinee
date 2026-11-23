# What Matinee should do next

Research from 2026-11-23, after the 2.4 release. Part 1 reviews the awkward features in Matinee and ranks fixes for them. Part 2 surveys what other streaming apps, Jellyfin plugins and Jellyfin users suggest building next. Nothing here is agreed yet.

Effort is for Roku, including entry-level TVs: **S** is under a day, **M** is a few days, **L** is a week or more, or new infrastructure.

## Part 1: Awkward features

### What was checked

The checks were done on the TCL 55R655 and in the code at `v2.4`.

| Finding | Where |
|---|---|
| **The \* key never reaches Matinee during playback.** Roku TVs open their own Settings menu (Sleep timer, Picture, Sound, Accessibility) and don't pass the key to the app. A debug build logged no `options` key at all. Moonfin's Roku client documents the same limit ("the * button is reserved by the Roku during video"). Matinee can't fix this. The README's "Anywhere: \* opens the subtitle choices" is wrong on Roku TVs and may be right on Roku sticks. | `PlayerScreen.bs` `onKeyEvent`; README "Playing" |
| **Mark Watched is a bare ✓ square** with no label. On a show it marks every episode at once, with no confirmation, and the page reloads. You can't mark a single episode or a season: OK on an episode Card plays it, and there's no other action. | `DetailsScreen.bs` `buildButtons`, `doButton` |
| **The Hero's My List button is a bare "+"**, while Details labels the same action "My List". Both only flip the icon, with no other feedback. | `BrowseScreen.bs` `heroButton`; `DetailsScreen.bs` |
| **You can add to My List only from the Hero and Details.** You can't add from a Card in a Row, from Search results or from Discover. You remove a title from the My List screen with \*, which nothing on screen hints at, apart from the count line. | `MyListScreen.bs` |
| **\* means something different on every screen.** On Rows it opens Details, on My List it removes the title, on Who's Watching it changes server, and in the player it should open subtitles. Nothing tells you which meaning applies where. | `BrowseScreen.bs`, `MyListScreen.bs`, `WhoScreen.bs` |
| **Back on Home exits Matinee straight away.** One extra Back after leaving the player drops you on the Roku Home. That happened during this review. | `BrowseScreen.bs` (`back` returns false in the `buttons` zone) |
| **Getting to Search:** Left from Play/Resume does open the Rail, contrary to the handoff note. But Up from the Hero goes to the server pill and the avatar, and OK on the avatar switches user straight away. That's how the last session switched profiles by accident. | `BrowseScreen.bs` `badges` zone |
| **Continue Watching can't be tidied.** There's no way to drop a title you gave up on. This is Jellyfin's second most-wanted feature (1,745 votes), and it's still unbuilt in Jellyfin 10.11.8. | — |
| **The README is out of date.** It says Rewind and Fast-forward jump 30 seconds; since 2.3 they start Scrubbing. | README "Playing" |

### How other apps handle it

- **Netflix** puts "Remove from Continue Watching" in a menu on the Details page and on a long press of a Card. Thumbs up and down sit on Details. ([Netflix help](https://help.netflix.com/en/node/115312), [Netflix announcement](https://about.netflix.com/news/now-you-can-easily-tidy-up-your-continue-watching-row-on-all-devices))
- **Plex** uses a long-press menu on any poster, episode, season or show, with Mark as played and unplayed. ([Plex forum](https://forums.plex.tv/t/marking-seasons-as-watched-or-unwatched/584908), [Plex forum](https://forums.plex.tv/t/feature-request-long-press-sub-menu-having-watched-unwatched-apple-tv4/132506))
- **Infuse** labels a "Mark as Watched" button next to Play on the episode screen and marks a whole season from a menu. ([Firecore community](https://community.firecore.com/t/have-to-hit-mark-as-watched-twice/34411))
- **The Apple TV app** offers, on any Up Next item: remove from Up Next, mark as watched, remove from recently watched. ([Tom's Guide](https://www.tomsguide.com/news/heres-the-one-upgrade-i-want-from-netflix-and-disney-plus-right-now))
- **Moonfin**, a Roku fork of jellyfin-roku with Seerr support, puts an Options button on Details and syncs Continue Watching and Next Up items hidden on the server through its Moonbase plugin. It documents nothing for marking watched. ([Moonfin Roku features](https://github.com/Moonfin-Client/Roku/wiki/Features), [user guide](https://github.com/Moonfin-Client/Roku/wiki/User-Guide))

The common pattern is **one Options menu per title**, with the same items wherever the title appears, opened by a long press or an Options button.

### Ranked fixes

1. **Title Options panel** (M, done). One small panel with the same actions for any title:
   - Play from the start
   - Mark watched / unwatched
   - Add to / Remove from My List
   - Remove from Continue Watching (when the title is there)
   - Go to show / Go to season (for episodes)

   It opens from Details as a labelled **"More"** button (replacing the bare ✓). From a Card in any Row, Search result, episode Card or My List, a **long press of OK** opens it. SceneGraph delivers key down and key up, so Matinee can time the hold, and that works on every remote. \* also opens it outside playback, as a shortcut. This settles what \* means everywhere except Who's Watching. The panel reuses the Track Picker's look, so it needs no new art.

   APIs: `POST/DELETE /UserPlayedItems/{id}` works on an episode, a season or a show. `/UserFavoriteItems/{id}` handles My List.
2. **Confirm "Mark the whole show watched"** (S). Marking a show or season watched shows a count first ("Mark 25 episodes watched?"). Marking one episode or movie doesn't ask.
3. **Feedback for My List and Watched** (S, done). A short toast ("Added to My List", "Marked watched") that fades after 2 s. Label the Hero's "+" as "My List", like Details.
4. **Stop relying on \* during playback** (S, done). Fix the README, and add a one-off tip in the player the first time: "Subtitles: press Down, then choose Subtitles". Keep \* working for Roku sticks, where it does arrive.
5. **Back on Home opens the Rail first** (S, done). The first Back opens the Rail with Home Focused, and a second Back exits. This matches Netflix and Max on Roku. It also gives a second route to Search, since the Rail's top icon is Search.
6. **Switching user takes a deliberate OK** (S, done). OK on the avatar opens Who's Watching instead of switching. That's one screen, and the person can press Back.
7. **Remove from Continue Watching** (S–M, done). Jellyfin has no native call for this yet (feature request #517 is "planned"). Matinee does both:
   - *With the DiscontinueWatching plugin* (installed on this server, v0.5.1): `POST /DiscontinueWatching/Items/{itemId}` hides the title for the signed-in User without losing the place, and `DELETE` on the same route un-hides it. Matinee fetches Continue Watching from `/DiscontinueWatching/Override/UserItems/Resume`, which takes the same query as `/UserItems/Resume` and leaves hidden titles out. Starting playback of a hidden title un-hides it. The plugin's README lists older routes (`/DiscontinueWatching`, `/DiscontinueWatching/{itemId}`) that 404; the routes above come from its controller source. The denylist routes need a User token (401 with an API key).
   - *No plugin:* the Override route 404s, so Matinee falls back to `/UserItems/Resume`, and Remove asks first, then marks the title unplayed, which clears its resume point.

## Part 2: Feature ideas

### What Jellyfin users ask for

The most-voted requests on [features.jellyfin.org](https://features.jellyfin.org/) as of 2026-11-23, filtered to what a TV client can do:

| Votes | Request | What Matinee could do |
|---|---|---|
| 1,745 | Remove an item from Continue Watching | Fix 7 above |
| 1,307 | Watchlist (like Netflix) | Already My List (ADR 0005) |
| 836 | Watched history | A "Recently watched" Row, or a page in My List (sort by `DatePlayed`) |
| 463 | Personal ratings | Thumbs up/down through `/UserItems/{id}/Rating?likes=`. Jellyfin stores it as `UserData.Likes` |
| 655 | Gapless playback | Music only; out of scope |
| 228 | Quick Connect with a QR code | Matinee already shows a code. Adding a QR code that opens the server's Quick Connect page is cheap |
| 223 | Buffer the next episode early | Already partly done: Matinee warms the transcode |

Top requests on the Android TV client by 👍 ([jellyfin-androidtv issues](https://github.com/jellyfin/jellyfin-androidtv/issues?q=is%3Aissue+sort%3Areactions-%2B1-desc+label%3Aenhancement)): SyncPlay (65), PIN-protected users (53), a playback info overlay (47), dual subtitles (36), backdrop video and theme song (35), subtitle and audio offset (32, 32), choosing tracks before playback starts (18), and on-demand subtitle search (16, which Matinee now has).

The official [jellyfin-roku issues](https://github.com/jellyfin/jellyfin-roku/issues) are mostly playback bugs. Feature asks there include a trailer button on series (Matinee has one), more playback speeds, subtitle info on the episode screen, and "marking all episodes of a season played fails silently" (#1074).

### Ideas, ranked

| # | Idea | User value | Effort | Needs |
|---|---|---|---|---|
| 1 | **Title Options panel** (Part 1) | Fixes the four most awkward spots at once | M | Nothing new |
| 2 | **Remove from Continue Watching** | Jellyfin's #2 request | S–M | Optional DiscontinueWatching plugin |
| 3 | **Profile PIN** | Keeps kids out of a parent's profile; #2 on Android TV | M | Store a PIN hash per Saved sign-in in the "Marquee" registry section. Jellyfin has no PIN API, so the PIN is per TV |
| 4 | **Playback info** ("why is this transcoding?") | Answers the most common Jellyfin support question | S | `PlaybackInfo` and the session's `TranscodingInfo`, already fetched |
| 5 | **Subtitle offset** | Fixes out-of-sync downloaded subtitles, which Find subtitles now makes likely | M | Roku has no offset API for text tracks. Matinee would have to draw subtitles itself or ask the server to re-time them. Needs a spike |
| 6 | **Thumbs up/down** on Details | Shapes "Picked for you". Netflix-style | S | `/UserItems/{id}/Rating` |
| 7 | **Recently watched** | Jellyfin's #9 request | S | `/Items?SortBy=DatePlayed&Filters=IsPlayed` |
| 8 | **Still watching?** after N episodes in a row | Stops a show playing all night on a TV left on; Netflix, Max and Moonfin all have it | S | Nothing new |
| 9 | **Skip Recap / Skip Credits** | Like Skip Intro | S | Jellyfin's media segments have Recap and Preview types, but on this server 400 episodes have only Intro and Outro. Check whether Intro Skipper's settings can detect recaps before building |
| 10 | **Choose subtitles and audio before playing** | Saves a trip into the player | S–M | Reuse the Track Picker on Details |
| 11 | **Theme songs and backdrops on Details** | Atmosphere; #6 on Android TV | S for theme music, L for backdrop video (heavy on entry-level TVs) | `/Items/{id}/ThemeSongs`; the AnimeThemes plugin (installed) adds anime openings |
| 12 | **Spoiler-safe episode Cards** | Hides the still and blurb of unwatched episodes; Moonfin has it | S | Nothing new |
| 13 | **Request from Search with one press**, and Seerr Watchlist in My List | Fewer steps | M | Seerr `/api/v1/watchlist` |
| 14 | **SyncPlay** | Watch together across houses; top Android TV request | L | Jellyfin SyncPlay WebSocket. Hard to keep in sync on Roku's player |
| 15 | **X-Ray-style cast while paused** | Prime Video's best feature | M | `People` on the item; cast photos cost memory on entry-level TVs |

### Jellyfin plugins worth using

On this server now: Intro Skipper, Open Subtitles, OMDb, TMDb, AnimeThemes, DiscontinueWatching, HoverTrailer, Media Bar, File Transformation, Moonbase and JellyTV. The last two serve other clients (Moonfin and JellyTV) and do nothing for Matinee.

| Plugin | What Matinee could use | Status |
|---|---|---|
| Intro Skipper | Intro and Outro, used by Skip Intro and the Up Next Prompt. Recap segments too, if it can detect them | Installed; used |
| DiscontinueWatching ([repo](https://github.com/jon4hz/jellyfin-plugin-discontinue-watching)) | Remove from Continue Watching without losing the place | Installed; used by Title Options |
| AnimeThemes | Theme songs for anime on Details | Installed; unused |
| Trakt (official) | Syncs watched status with Trakt; nothing for Matinee to do | Optional |
| Open Subtitles | Find subtitles | Installed; used since 2.4 |
| OMDb | Rotten Tomatoes in Ratings | Installed; used |

Lists of plugins: [awesome-jellyfin](https://github.com/awesome-jellyfin/awesome-jellyfin), [Ultimate list](https://github.com/cjlong45/Ultimate-List-of-Jellyfin-Plugins). Most "best of 2026" articles come from sites promoting their own hubs, so I treated them as opinion.

### Competitor to watch

**Moonfin for Roku** ([repo](https://github.com/Moonfin-Client/Roku)) is a fork of jellyfin-roku with Seerr requests, themes, watch parties, a calendar with a spoiler-safe mode, synced settings through its Moonbase plugin, and nine Details layouts. It's the closest thing to Matinee. Matinee's edge is a calmer, Netflix-like design kept light for entry-level TVs. Moonfin's is breadth.

## Sources

- Jellyfin feature requests, most wanted: https://features.jellyfin.org/ (API `GET /api/v1/posts?view=most-wanted`)
- jellyfin-androidtv issues by 👍: https://github.com/jellyfin/jellyfin-androidtv/issues
- jellyfin-roku issues: https://github.com/jellyfin/jellyfin-roku/issues
- Moonfin Roku features and user guide: https://github.com/Moonfin-Client/Roku/wiki/Features, https://github.com/Moonfin-Client/Roku/wiki/User-Guide
- DiscontinueWatching plugin: https://github.com/jon4hz/jellyfin-plugin-discontinue-watching
- Jellyfin design discussion, Remove from Continue Watching: https://github.com/jellyfin/jellyfin-meta/discussions/50
- Netflix, removing from Continue Watching: https://help.netflix.com/en/node/115312
- Plex, marking seasons watched: https://forums.plex.tv/t/marking-seasons-as-watched-or-unwatched/584908
- Infuse, Mark as Watched: https://community.firecore.com/t/have-to-hit-mark-as-watched-twice/34411
- Prime Video X-Ray Recaps: https://techcrunch.com/2024/11/04/amazon-brings-generative-ai-powered-recaps-to-prime-video
- Plugin round-up (opinion): https://www.jellywatch.app/blog/awesome-jellyfin-plugins-complete-guide-2026
