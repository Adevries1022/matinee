# Matinee: a Jellyfin app for Roku

Matinee is a Roku app for Jellyfin, with requests through Seerr and downloads from Radarr and Sonarr.

> **This source is an unreleased rebuild.** It still reports version 2.3.1, but looks and works differently from the v2.3 releases, and parts of it have had little or no testing on a TV.

## Install or update (sideload)
1. **Turn on Developer Mode on the Roku** (first time only). On the remote, press Home 3 times, Up 2 times, then Right, Left, Right, Left, Right. Accept the terms, set a password, and let the Roku restart. Write down the IP address it shows.
2. Build `dist/matinee.zip` from source (see [Building from source](#building-from-source)). The zips from v2.3 and earlier don't include the rebuild.
3. On a computer on the same network, open `http://<roku-ip>` in a browser. Sign in with the username `rokudev` and your password.
4. Click **Upload**, choose the zip, then click **Install with zip** (or **Replace**).
5. If Matinee asks, pick your server, then pick your name on **Who's watching?**. Approve the code it shows: in Jellyfin on your phone, go to your profile → **Quick Connect** and enter it. You can also press OK to use your password.

Updating keeps your server and sign-ins. **Going back to v2.3.x after installing this build means everyone signs in again**, because sign-ins are now saved per server and older versions can't read them.

Needs Jellyfin 10.9 or newer. Seerr, Radarr and Sonarr are optional.

## Features

### Watching
- **Home:** a Hero for the title you're on, with Play or Resume, Details and My List. Focus starts on those buttons, at the bottom left, with only the tops of the Rows showing below; press Down to slide the Rows up. Optionally, staying on a title starts it: turn on "Start a title you stay on" in Playback & quality (off by default) and it plays when its trailer ends, or after 12 seconds if it has none, with a "Starting in 5" countdown first. The Rows are for Continue watching, Next up, Recently added, Picked for you and Highly rated.
- **Series and Movies:** every show or movie from all your libraries, with Rows for what you're watching, what's new, what you haven't watched, and up to 14 genres.
- **Details:** seasons and episodes for shows, More like this for movies (similar titles from your library, then Seerr's recommendations you can request), and buttons for My List, Start over (a movie you've started), Trailer and More.
- **Title Options:** hold OK on any title (a Card in a Row, an episode, a search result, My List), or press *, for a short list of actions: Play from the start, Mark watched or unwatched, Add to or Remove from My List, and Go to the show for an episode. More on Details opens the same list for the title on screen. Marking a whole show or season watched asks first.
- **Ratings:** the Hero, Details and Discover show IMDb and Rotten Tomatoes scores. Rotten Tomatoes comes from Jellyfin when its OMDb plugin has filled it in; IMDb, and Rotten Tomatoes for series, come from Seerr while you're signed in to it. When neither is known, TMDB's score shows instead.
- **My List:** your Jellyfin Favorites (movies and shows), so it's the same on every device. Filter by All, In progress or Not started.
- **Search:** finds titles by name as you type. Up to three Suggestions under the keys finish the title you're typing, and the top one shows faintly in the search field. Pick one to jump to its results. If you're signed in to Seerr, titles you could request follow the matches from your library.
- **Player:** Matinee's own controls, with seeking, subtitle and audio choice, the next episode, and a countdown near the end of an episode. Picture-based subtitles (like PGS) are burned in by the server.
- **Find subtitles:** at the bottom of the Subtitles list, "Find English subtitles…" (in your preferred subtitle language) searches Jellyfin's subtitle plugins for the playing title. Pick a result and Jellyfin saves it next to the video, then playback picks up where it was with the new subtitles on. This needs a subtitle plugin on the server, such as Open Subtitles (Dashboard › Plugins › Catalog, then your opensubtitles.com sign-in in its settings), and a Jellyfin account that is allowed to manage subtitles.
- **Trailer Preview:** stay on a title for about 3 seconds on Home, Series or Movies and its trailer plays behind the Hero, shifted right so you can see it clearly, with sound (turn Trailer sound off in Playback & quality to start them muted). The header fades out while it plays.

### Requests and downloads
- **Discover** appears in the Rail when Matinee finds Seerr. Until an Administrator enters an address, it looks on port 5055 of the Jellyfin machine, then at seerr.home, seerr.lan, seerr.local and seerr, and keeps the first that answers. Each person signs in to Seerr with their Jellyfin account, so requests are in their name. It's for browsing what to request: Rows of trending, popular and coming-soon movies and series, then streaming services (Netflix, Prime Video, Disney+ and others in Seerr's region) and genres. A service or genre opens a page laid out the same way, with Rows of popular, new and top rated movies and series. OK on a title opens its Request Details: artwork, scores, the story and a Request button, with season pills for shows and More like this below. Once it's requested, the Request Status shows where the button was.
- **My requests** sits under Discover in the Rail. It's the one place for current requests. It lists your requests that aren't ready yet (waiting for approval, looking for a download, or downloading), with a progress bar for each download from Seerr. While any are downloading, its Rail icon shows how many.
- A show can be requested as all seasons (or the rest of them, when some are already there) or one season, picked with the season pills; seasons on the server have a check. **4K** is offered, as a second button, only when "Show 4K requests" is on and Seerr has a 4K server for that kind of title. "Default request quality" decides which of the two comes first.
- **Radarr and Sonarr** can be set up from Seerr: in Settings › Servers & services › Seerr, an Administrator whose Seerr account can manage Seerr's settings picks "Set up from Seerr". Matinee copies the address and API key Seerr uses and keeps the first address that answers from the TV. While Seerr is signed in, Radarr and Sonarr aren't listed in Servers & services until they're set up. They're optional: My Requests shows download progress through Seerr without them. They're listed for typing in by hand when Seerr isn't signed in or couldn't set them up.
- **Activity** appears once Radarr or Sonarr is set up, with the download queue, what's coming up this week and storage space. Anyone can look; only an Administrator can remove a download. "Show queue on Home" adds a Row of downloads.

### Settings
| Section | What's there | Who can change it |
|---|---|---|
| Servers & services | Jellyfin, Seerr, Radarr and Sonarr, the away address, Test connection, Add another server | Administrators. Each person controls their own Seerr sign-in, bitrate and Direct play |
| Themes | Six Themes, five Accents or the Theme's default, Larger text, Portrait posters | Each person, for themselves |
| Users | Switch user, Manage profiles, Sign out | Anyone |
| Users | Always show Who's watching | Administrators |
| Playback & quality | Bitrate, Direct play, Trailer previews, Trailer sound, playing the next episode automatically | Each person, for themselves |
| Subtitles | On, off or the server's default, and a preferred language | Each person, for themselves |
| About this device | Matinee, Roku and server details | View only |

### Servers and sign-ins
- **Connect** finds servers on your network, takes a typed address, or signs you in with Quick Connect on the server you highlighted or entered.
- Sign-ins are saved separately for each server. Manage profiles on Who's watching forgets one.
- **Who's watching?** opens at start when more than one person could be watching, or every time if "Always show Who's watching" is on.
- An **away address** belongs to one server and is tried at start when that server's main address doesn't answer.
- After an Administrator first signs in to a server, an optional step offers to set up the other services.

## Remote controls

### Getting around
| Where | Button | What it does |
|---|---|---|
| Home, Series, Movies, Search, My List, Requests, My requests, Activity | Left from the leftmost item | Opens the Rail |
| Rail | Up / Down, then OK | Goes to that screen |
| Rail | Right or Back | Closes it |
| Most screens | Back | Goes back. From Home or Who's watching, exits Matinee |

### Home, Series and Movies
| Where | Button | What it does |
|---|---|---|
| Any Row | OK | Opens details (or Activity, for a download). Play on the remote plays it, picking up where you left off |
| Any Row, Search result or My List | Hold OK, or * | Opens Title Options |
| Details, on a button | * | Opens Title Options for the title |
| Details, on an episode | Hold OK, or * | Opens Title Options for that episode |
| First Row | Up | Moves to Play, Details and My List |
| Play, Details and My List | Up | Moves to the server pill (opens Settings) and your avatar (switches user) |
| Any Row or button | Play | Turns a playing Trailer Preview's sound on or off. With none playing, plays the Hero's title |
| Rows, away from the first Card | Back | Jumps to the first Card |

### Other screens
| Where | Button | What it does |
|---|---|---|
| Details | Up / Down | Moves between the back pill, buttons, seasons and Cards |
| Details, on the seasons | Left / Right | Shows another season |
| Details, on a button | Play | Plays or resumes |
| Search, on the keys | Right past the last column | Moves to the results |
| Search, on the keys | Instant Replay | Deletes a letter |
| Search, on the keys | Down from Space, Delete or Clear | Moves to the Suggestions |
| Search, on a Suggestion | OK | Searches for that title and moves to its results |
| Search, on the Suggestions | Up from the first, or Back | Returns to the keys |
| Search, in the results | Left from the first column, or Back | Returns to the keys |
| My List, Requests, Activity | Up from the top | Moves to the filters or tabs |
| Discover | OK | Opens Detail for an available title, or Request Details for one you can ask for |
| Activity | OK | Administrators: asks before removing the download |
| Settings | Right or OK / Left or Back | Goes into a section / back out (Themes opens with OK) |
| Settings, on a value | OK | Changes it to the next choice, or opens the keyboard |
| Who's watching? | Down | Moves to Manage profiles |
| Who's watching? | * | Changes server (anyone can) |
| Connect | Right or OK / Left or Back | Goes into a method / back to the list |
| Connect, on the list of methods | Back | Cancels if you opened it from inside Matinee; otherwise exits |
| Sign in | OK or Play | Uses a password instead of the code |
| Keyboard | Play, or Down then OK | Done |
| Keyboard | Back | Cancels |

### Playing
| Where | Button | What it does |
|---|---|---|
| Controls hidden | OK, Up or Down | Shows the controls. They hide again after 5 seconds |
| Controls hidden, or on the seek bar | Left / Right | Back or forward 10 seconds. Presses add up before the jump |
| Seek bar | OK | Pauses or resumes |
| Controls showing | Up / Down | Moves between the back button, seek bar and buttons |
| Anywhere | Play/Pause | Pauses or resumes |
| Anywhere | Rewind / Fast-forward | Back or forward 30 seconds |
| Anywhere | * | Opens the subtitle choices on a Roku stick or box. Roku TVs keep * for their own picture and sound menu during video, so use Down to the Subtitles button there |
| Subtitle or audio choices | OK | Chooses |
| Subtitle or audio choices | Back, Left or * | Closes |
| Find subtitles | OK on a result | Downloads it and turns it on |
| Find subtitles | Back or Left | Returns to the subtitle choices |
| End-of-episode countdown | OK or Play | Plays the next episode now |
| End-of-episode countdown | Back | Keeps watching |
| Anywhere else | Back | Stops and leaves the Player |

## Limits
- **Self-signed certificates** are accepted for API calls only, and are allowed by default (turn "Allow self-signed certificates" off on Connect to refuse them). The Roku loads video and artwork itself, so those need a certificate it trusts.
- **Trailers** are only those stored on your Jellyfin server; online trailer links aren't played. Trailarr can download trailers for your library.
- **Downloads can't be paused**, because Radarr and Sonarr can't pause them. Removing one also removes it from the download client.
- **Administrator-only settings don't lock the TV:** anyone can change the server from Who's watching.
- **View only:** which libraries are shown, Radarr and Sonarr's quality profile and root folder, and Seerr's auto-approve.
- The seek bar doesn't show what's buffered and has no thumbnails.
- Subtitle size and style come from the Roku's own captions settings.

## Not yet
Music, Live TV, Collections Rows.

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
