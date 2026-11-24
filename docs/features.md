# Matinee features and remote controls

Everything Matinee does, screen by screen. For installing and first-time setup, see the [README](../README.md).

## Features

### Watching
- **Home:** a Hero for the title you're on, with Play or Resume, Details and My List. Focus starts on those buttons, at the bottom left, with only the tops of the Rows showing below; press Down to slide the Rows up. Optionally, staying on a title starts it: turn on "Start a title you stay on" in Playback & quality (off by default) and it plays when its trailer ends, or after 12 seconds if it has none, with a "Starting in 5" countdown first. The Rows are Ready to watch, Continue watching, Next up, Recently added, Picked for you and Highly rated; Collections, Trending to request and Coming soon to request (both need Seerr) are off until you turn them on. Show, hide and reorder them in Settings › Home. A Seerr title on Home shows Request and Details instead of Play, and OK opens its Request Details.
- **Series and Movies:** every show or movie from all your libraries, with Rows for what you're watching, what's new, what you haven't watched, and up to 14 genres.
- **Details:** seasons and episodes for shows, More like this for movies (similar titles from your library, then Seerr's recommendations you can request), and buttons for My List, Start over (a movie you've started), Trailer and More. A movie's meta line says when it would end if you started it now ("Ends at 10:42 PM", from where you left off), following the TV's 12- or 24-hour clock.
- **Title Options:** hold OK on any title (a Card in a Row, an episode, a search result, My List), or press *, for a short list of actions: Play from the start, Remove from Continue watching, Mark watched or unwatched, Add to or Remove from My List, and Go to the show for an episode. More on Details opens the same list for the title on screen. Marking a whole show or season watched asks first. A short message at the bottom confirms each change.
- **Remove from Continue watching:** in Title Options on a Continue watching Card. With the [DiscontinueWatching](https://github.com/jon4hz/jellyfin-plugin-discontinue-watching) plugin on the server, the title is hidden and keeps your place, and playing it again brings it back. Without the plugin, Matinee asks first and then clears where you stopped.
- **Ratings:** the Hero, Details and Discover show IMDb and Rotten Tomatoes scores. Rotten Tomatoes comes from Jellyfin when its OMDb plugin has filled it in; IMDb, and Rotten Tomatoes for series, come from Seerr while you're signed in to it. When neither is known, TMDB's score shows instead.
- **Collections:** a collection (a Jellyfin BoxSet, such as a film series) opens its own page, laid out like Details, with its films and shows in a Row.
- **My List:** your Jellyfin Favorites (movies and shows), so it's the same on every device. Filter by All, In progress or Not started.
- **Search:** finds titles by name as you type. Up to three Suggestions under the keys finish the title you're typing, and the top one shows faintly in the search field. Pick one to jump to its results. If you're signed in to Seerr, titles you could request follow the matches from your library.
- **Player:** Matinee's own controls, with seeking, subtitle and audio choice, the next episode, and a countdown near the end of an episode. The seek bar shows when the title will end ("Ends at 10:42 PM"). Picture-based subtitles (like PGS) are burned in by the server.
- **Plays what your Roku can play:** Matinee tells Jellyfin exactly which video and audio formats this Roku handles (10-bit H.264 never, HEVC 10-bit, AV1, DTS and TrueHD only when it can, surround AAC as stereo), so the server converts only what it must, often just the sound. Jumping far ahead in a converted video restarts the conversion at the new spot.
- **Subtitles:** a forced track in the language you're listening to (signs and foreign dialogue) turns on by itself. Matinee follows the Roku's own captions setting, and turning captions on or off from Roku's * menu picks or clears a subtitle. **Subtitle timing**, in the subtitle choices, moves text subtitles earlier or later in half-second steps; applying it reloads the video at the same spot.
- **Still watching?** After three episodes in a row with no button pressed, Matinee asks before starting the next one (turn it off in Playback & quality).
- **Skip intro:** during an episode's intro, a Skip intro button shows at the bottom right; OK jumps past the intro. When the end credits start, the Up next countdown comes up (or 25 seconds before the end when the server doesn't know where the credits are). Turn on "Skip intros automatically" in Playback & quality to skip without a press (the first episode you start still plays its intro). Both need the [Intro Skipper](https://github.com/intro-skipper/intro-skipper) plugin, or another plugin that fills in Jellyfin's media segments.
- **Find subtitles:** at the bottom of the Subtitles list, "Find English subtitles…" (in your preferred subtitle language) searches Jellyfin's subtitle plugins for the playing title. Pick a result and Jellyfin saves it next to the video, then playback picks up where it was with the new subtitles on. This needs a subtitle plugin on the server, such as Open Subtitles (Dashboard › Plugins › Catalog, then your opensubtitles.com sign-in in its settings), and a Jellyfin account that is allowed to manage subtitles.
- **Trailer Preview:** stay on a title for about 3 seconds on Home, Series or Movies and its trailer plays behind the Hero, shifted right so you can see it clearly, with sound (turn Trailer sound off in Playback & quality to start them muted). The header fades out while it plays.

### Requests and downloads
- **Discover** appears in the Rail when Matinee finds Seerr. Until an Administrator enters an address, it looks on port 5055 of the Jellyfin machine, then at seerr.home, seerr.lan, seerr.local and seerr, and keeps the first that answers. Each person signs in to Seerr with their Jellyfin account, so requests are in their name. It's for browsing what to request: Rows of trending, popular and coming-soon movies and series, then streaming services (Netflix, Prime Video, Disney+ and others in Seerr's region) and genres. A service or genre opens a page laid out the same way, with Rows of popular, new and top rated movies and series. OK on a title opens its Request Details: artwork, scores, the story and a Request button, with season pills for shows, More in this collection for a film in a series of films, and More like this below. Once it's requested, the Request Status shows where the button was.
- **My requests** sits under Discover in the Rail. It's the one place for current requests. It lists your requests that aren't ready yet (waiting for approval, looking for a download, or downloading), with a progress bar for each download and, when a download is stuck, why ("Stalled: no connections", "Waiting to import"). While any are downloading, its Rail icon shows how many.
- **Approve and decline:** people whose Seerr account can manage requests see everyone's requests waiting for approval at the top of My requests, with Approve and Decline (Decline asks first). A second number on the Rail icon counts them.
- **Ready to watch:** when one of your requests arrives on the server, a message says so on whatever screen you're on (after the video, if you're watching one), and the title waits in the Ready to watch Row on Home until you play it.
- **Report a problem:** on Request Details for a title that's on the server, report a video, audio or subtitle problem (for a show, with the season and episode) to whoever runs Seerr. Needs a Seerr account that can report issues.
- **Request** opens the request sheet at the right: for a show, the seasons (all, the rest, or any of them; seasons already there are checked), **HD or 4K** (only when "Show 4K requests" is on and Seerr has a 4K server for that kind of title), how many requests you have left this week, and, for people who can, the server, quality profile and folder. "Request the collection" on a film lists the films in its collection to request together.
- **Radarr and Sonarr** can be set up from Seerr: in Settings › Servers & services › Seerr, an Administrator whose Seerr account can manage Seerr's settings picks "Set up from Seerr". Matinee copies the address and API key Seerr uses and keeps the first address that answers from the TV. While Seerr is signed in, Radarr and Sonarr aren't listed in Servers & services until they're set up. They're optional: My Requests shows download progress through Seerr without them. They're listed for typing in by hand when Seerr isn't signed in or couldn't set them up.
- **Activity** appears once Radarr or Sonarr is set up, with the download queue, what's coming up this week and storage space. Anyone can look; only an Administrator can remove a download. "Show queue on Home" adds a Row of downloads.

### Settings
| Section | What's there | Who can change it |
|---|---|---|
| Servers & services | Jellyfin, Seerr, Radarr and Sonarr, the away address, Test connection, Add another server | Administrators. Each person controls their own Seerr sign-in, bitrate and Direct play |
| Themes | Six Themes, five Accents or the Theme's default, Larger text, Portrait posters | Each person, for themselves |
| Home | Show, hide and reorder Home's Rows (Ready to watch, Continue watching, Next up, Recently added, Collections, two Seerr Rows, Picked for you, Highly rated), Reset to default | Each person, for themselves |
| Users | Switch user, Manage profiles, Sign out | Anyone |
| Users | Always show Who's watching | Administrators |
| Playback & quality | Bitrate, Direct play, Trailer previews, Trailer sound, playing the next episode automatically, Skip intros automatically, Ask if you're still watching | Each person, for themselves |
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
| Most screens | Back | Goes back. From Who's watching at start, exits Matinee |
| Home, on Play, Details and My List | Back | Opens the Rail on Home. Back again exits Matinee |

### Home, Series and Movies
| Where | Button | What it does |
|---|---|---|
| Any Row | OK | Opens details (or Activity, for a download). Play on the remote plays it, picking up where you left off |
| Any Row, Search result or My List | Hold OK, or * | Opens Title Options |
| Details, on a button | * | Opens Title Options for the title |
| Details, on an episode | Hold OK, or * | Opens Title Options for that episode |
| First Row | Up | Moves to Play, Details and My List (Request and Details for a Seerr title; Details and My List for a collection) |
| Play, Details and My List | Up | Moves to the server pill (opens Settings) and your avatar (opens Who's watching; Back keeps you signed in) |
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
| Settings › Home, on a Row | OK / Rewind or Fast-forward | Shows or hides it / moves it up or down |
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
| Anywhere | Rewind / Fast-forward | Scrubs back or forward. Press again for 4×, 15× and 60×; OK jumps there, Back cancels |
| Anywhere | Instant Replay | Back 10 seconds |
| Anywhere | * | Opens the subtitle choices on a Roku stick or box. Roku TVs keep * for their own picture and sound menu during video, so press Down twice and choose Subtitles there. The first video on a Roku TV says so |
| Subtitle or audio choices | OK | Chooses |
| Subtitle or audio choices | Back, Left or * | Closes |
| Find subtitles | OK on a result | Downloads it and turns it on |
| Find subtitles | Back or Left | Returns to the subtitle choices |
| Skip intro showing, controls hidden | OK | Jumps past the intro |
| End-of-episode countdown | OK or Play | Plays the next episode now |
| End-of-episode countdown | Back | Keeps watching |
| Still watching? | OK on Continue watching or Stop | Plays the next episode, or leaves the Player. Back also leaves |
| Subtitle timing | Left / Right, then OK | Earlier or later by half a second, then applies. Back cancels |
| Anywhere else | Back | Stops and leaves the Player |

## Limits
- **Self-signed certificates** are accepted for API calls only, and are allowed by default (turn "Allow self-signed certificates" off on Connect to refuse them). The Roku loads video and artwork itself, so those need a certificate it trusts.
- **Trailers** are only those stored on your Jellyfin server; online trailer links aren't played. Trailarr can download trailers for your library.
- **Downloads can't be paused**, because Radarr and Sonarr can't pause them. Removing one also removes it from the download client.
- **Administrator-only settings don't lock the TV:** anyone can change the server from Who's watching.
- **View only:** which libraries are shown, Radarr and Sonarr's quality profile and root folder, and Seerr's auto-approve.
- The seek bar doesn't show what's buffered. Thumbnails show while seeking only when Jellyfin has made trickplay images for the library (Jellyfin 10.9 and newer).
- Subtitle size and style come from the Roku's own captions settings.

## Not yet
Music and Live TV.
