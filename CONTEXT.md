# Matinee

A Roku client for Jellyfin media servers, built to feel like a polished streaming app rather than a generic media browser. Meant to be shared with other Jellyfin households.
_Avoid_: Marquee (the working name), Lumen (the design boards' name), Jellyflix, Netfin

## Language

### Look and feel

**Theme**:
A named, per-User color scheme for the whole app. There are six: **Midnight** (the default), **OLED Black**, **Slate**, **Forest**, **Ember** and **Dusk**, each with its own Accent.
_Avoid_: Skin, style, mode, layout

**Accent**:
The one highlight color used for focus, progress and emphasis: Amber, Sky, Coral, Lime or Violet, or the Theme's default.
_Avoid_: Brand color, highlight color

**Larger text**:
A per-User setting that enlarges all of Matinee's text.
_Avoid_: Zoom, font size

**Portrait posters**:
A per-User setting that shows tall Cards in the Rows of movies and shows. Continue Watching, Next Up and downloads stay landscape.
_Avoid_: Poster mode, layout

### Getting around

**Rail**:
The always-visible column of icons down the left edge that leads to each main screen.
_Avoid_: Side Rail, sidebar, drawer, menu bar, Top Bar

**Focused**:
The Card, Rail icon or control the remote's highlight is on. A Focused button is the only solid one, so it's always clear what OK will press.
_Avoid_: Hover, hovered, selected (selecting means pressing OK)

**Hero**:
The large area at the top of Home, Series and Movies showing the Focused title's artwork, name, details and actions.
_Avoid_: Banner, billboard, spotlight

**Logo**:
A title's own name artwork from Jellyfin (a transparent image), drawn in place of the text title in the Hero, on Detail and in the Player header. Episodes use their show's Logo; titles without one, such as Seerr results, keep the text title.
_Avoid_: Title art, clear logo, wordmark

**Row**:
A titled, horizontally scrolling list of Cards.
_Avoid_: Shelf, carousel, lane

**Card**:
One title's artwork in a Row or grid, either portrait or landscape.
_Avoid_: Tile, item, poster (when meaning the general concept)

### Browsing

**Series**:
The main screen with every show from all of the server's show libraries.
_Avoid_: TV library, Shows screen

**Movies**:
The main screen with every movie from all of the server's movie libraries.
_Avoid_: Film library

**Ratings**:
A title's IMDb and Rotten Tomatoes scores in its meta line, with TMDB's score when neither is known.
_Avoid_: Reviews, stars

**Auto-play**:
Off unless "Start a title you stay on" is turned on in Playback & quality. Staying on a title in the Hero until its Trailer Preview ends, or for 12 seconds when it has none, opens the player and starts it. A title the User is Watching skips its Trailer Preview: after 12 seconds it resumes, or starts the next episode. The last 5 seconds show the Auto-play Countdown. Any key press restarts the wait (during a Trailer Preview's Countdown, it waits the full time again after the trailer ends).
_Avoid_: Autoplay next (that's the next episode, in the player)

**Auto-play Countdown**:
The "Starting in 5" pill at the bottom right of the Hero, with an Accent bar filling under the number, over the last 5 seconds before Auto-play starts a title, including the end of a Trailer Preview. It takes the place of the trailer sound hint.
_Avoid_: Up Next Prompt (that's in the player)

**Watching**:
A title the User is partway through: a movie or episode with a resume point, an unwatched episode, or a show with some but not all episodes watched.
_Avoid_: In progress, started

**Trailer Preview**:
A title's trailer, stored on the server, playing large behind the Hero text, shifted right so more of it shows, with its edges fading into the screen, after its Card has been Focused for 5 seconds. It has sound unless Trailer sound is off, and the header fades out while it plays.
_Avoid_: Autoplay, preview video

**Continue Watching**:
Titles the User started but didn't finish.
_Avoid_: Resume list, in progress

**Next Up**:
The next unwatched episode of each show the User is following.
_Avoid_: Up next (that name belongs to the following episode during playback)

**My List**:
The movies and shows a User saved for later. These are that User's Jellyfin Favorites, so they are the same on every device.
_Avoid_: Watchlist, bookmarks, queue

**Search**:
The one place to look up a title by name, both in the library and among titles that can be Requested.
_Avoid_: Discover search, request search

**Suggestion**:
A title under the Search keys that finishes what's being typed, taken from the current results. The top one also shows faintly in the query field. Choosing one searches for that title and moves to its results.
_Avoid_: Autocomplete, hint

### Playback

**Player OSD**:
Matinee's own on-screen playback controls: the title, seek bar, buttons and Up Next Card. Back hides it and playback carries on; Back with it hidden leaves the player.
_Avoid_: Trickplay bar, HUD, player UI

**Skip Intro**:
The button that shows while playback is inside a title's Intro, as marked by the server's media segments (the Intro Skipper plugin). It is Focused while the Player OSD is hidden, so OK jumps past the Intro.
_Avoid_: Skip opening, skip credits

**Scrubbing**:
Moving through a title fast in the Player OSD, with the picture paused: Fast-forward or Rewind starts it and pressing again goes faster (three speeds); holding Left or Right does it until let go, speeding up the longer it's held (2x after 2 seconds, 3x after 5). A Trickplay Preview shows where it will land. Letting go, OK or Play jumps to the spot; Back cancels.
_Avoid_: Trickplay, seeking (one 10-second jump)

**Trickplay Preview**:
The small picture over the seek bar while seeking or Scrubbing, from the thumbnails Jellyfin makes when trickplay image extraction is on for a library.
_Avoid_: Thumbnail scrubbing, BIF

**Track Picker**:
The panel during playback for choosing subtitles or the audio track.
_Avoid_: Language menu, options menu

**Up Next Card**:
The part of the Player OSD that names the following episode. It shows only while the Next episode button is Focused.
_Avoid_: Next Up

**Up Next Prompt**:
A small card at the bottom right that offers to play the following episode: its picture with the countdown as a bar filling along the bottom, then its name. It comes up when the end credits (the Outro segment) start, or 25 seconds before the end when the server doesn't know where they are.
_Avoid_: Autoplay screen, Up Next Card

### Requests and downloads

**Seerr**:
The household's separate request app, which adds titles to the server when someone asks for them.
_Avoid_: Jellyseerr, Overseerr

**Request**:
A User asking Seerr to add a movie, or some or all seasons of a show, in their own name.
_Avoid_: Download, add

**Discover**:
The main screen for browsing titles to Request: a Hero and Rows of trending, popular and coming-soon titles, then streaming services and genres. Each service or genre opens a Discover category, laid out the same way: a Hero and Rows of popular, new and top rated titles (a genre adds coming soon). Search is for a title you already know.
_Avoid_: Requests screen, Explore, Discover grid

**Request Details**:
The screen for one title that can be Requested, laid out like Detail: Request in place of Play, season pills for shows that pick what Request sends, the Request Status once it's requested, Watch when part of it is on the server, and More like this. A second "Request in 4K" button appears only when 4K is really on offer. Titles that are all on the server open their Detail instead.
_Avoid_: Request panel, request dialog

**My requests**:
The main screen listing a User's own Requests that aren't ready to watch yet (titles that are ready drop off, since they're in the library), with a progress bar for each download. Its Rail icon shows how many are downloading.
_Avoid_: Downloads, request queue

**Request Status**:
Where a title stands in Seerr: Not requested, Pending approval, Downloading, Partly available or Available.
_Avoid_: Download state

**Radarr**:
The household's separate app that downloads and organizes movies.
_Avoid_: Movie Seerr, downloader

**Sonarr**:
The household's separate app that downloads and organizes shows.
_Avoid_: TV Seerr, downloader

**Activity**:
The main screen showing what Radarr and Sonarr are downloading, what is coming up this week, and storage space.
_Avoid_: Downloads screen, queue screen

### Setup and Settings

**Settings**:
The screen for a User's own choices and for the settings that belong to the whole TV.
_Avoid_: Preferences, options, admin page

**Servers & services**:
The section of Settings for Jellyfin, Seerr, Radarr and Sonarr on this TV. While Seerr is signed in, Radarr and Sonarr are listed only once they're set up. Anyone can view it; only Administrators can change the services.
_Avoid_: Connections, admin page

**Connect**:
The screen for choosing a Jellyfin server, by Server Discovery, by address or by Quick Connect.
_Avoid_: Server picker, login

**Server Discovery**:
Finding Jellyfin servers on the home network automatically.
_Avoid_: Scan, auto-detect

**Away address**:
A second address for one Jellyfin server, for when the TV is outside that server's home network. It is never used for another server.
_Avoid_: Fallback server, backup server

**Quick Connect**:
Jellyfin's sign-in method where the TV shows a short code and the User approves it from another signed-in device.
_Avoid_: Pairing, device code

### People

**User**:
A Jellyfin account on the server. Each person in the household is a User.
_Avoid_: Profile (except in the on-screen labels "Add profile" and "Manage profiles"), account

**Administrator**:
A User whom Jellyfin marks as an administrator. Only Administrators change what belongs to the whole TV from inside Settings or remove downloads in Activity.
_Avoid_: Admin user, owner

**Saved sign-in**:
A User's sign-in kept on this TV for one server, so they can pick their name without signing in again. Forgetting it means signing in again.
_Avoid_: Session, saved profile

**Who's Watching**:
The screen where the person watching picks which User they are.
_Avoid_: Profile picker, user select
