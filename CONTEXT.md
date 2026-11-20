# Matinee

A Roku client for Jellyfin media servers, built to feel like a polished streaming app rather than a generic media browser. Meant to be shared with other Jellyfin households.
_Avoid_: Marquee (the working name), Jellyflix, Netfin

## Language

### Look and feel

**Theme**:
A named, user-selectable skin that changes how Marquee looks. Users can switch Themes in the app.
_Avoid_: Skin, style, mode

**Midnight Glass**:
The default Theme: a pure-black base, rounded Cards, frosted panels over artwork, and one Accent.

**Void**:
A Theme that is pure black, flat and sharp-cornered, where only the artwork carries color.

**Amber**:
A Theme that keeps the original v1 look: square Cards and an amber Accent.
_Avoid_: Marquee Classic, Classic

**Accent**:
The single highlight color a Theme uses for focus, progress, and emphasis.
_Avoid_: Brand color, highlight color

**Layout Add-on**:
An optional change to the browse screens that can be combined with any Theme and with other Layout Add-ons.
_Avoid_: Mod, tweak, layout theme

**Big Hero**:
A Layout Add-on that makes the Hero taller, using full-bleed artwork with minimal text.

**Mini Cards**:
A Layout Add-on that uses smaller Cards so more fit on screen.

**Reduce Motion**:
A setting that turns off non-essential movement such as Card zoom and backdrop crossfades.

**Settings**:
The screen, reached from the main menu, with two sections: Appearance and Connections. Each setting opens a short list of its options, and moving through the list previews each one live.
_Avoid_: Preferences, options, admin page

**Appearance**:
The per-User section of Settings: Theme, Accent, Layout Add-ons, Navigation Style and Reduce Motion. Changes show live.

**Connections**:
The section of Settings that applies to the whole TV: the Jellyfin server, Seerr, and whether Who's Watching always appears. Anyone can view it; only Administrators can change it.
_Avoid_: Admin page, server settings

**Administrator**:
A User whom Jellyfin marks as an administrator.
_Avoid_: Admin user, owner

**Navigation Style**:
A user setting for where the main menu lives, either the **Side Rail** or the **Top Bar**. It is separate from the Theme.
_Avoid_: Layout, nav mode

**Side Rail**:
The Navigation Style with icons down the left edge that expand into labels when focused.
_Avoid_: Sidebar, drawer

**Top Bar**:
The Navigation Style with a text menu along the top of the screen, reached by pressing Up from the first row.
_Avoid_: Header, tab bar

### Browsing

**Hero**:
The large area at the top of a browse screen showing the focused title's backdrop, name, details and description.
_Avoid_: Banner, billboard, spotlight

**Row**:
A titled, horizontally scrolling list of Cards on a browse screen.
_Avoid_: Shelf, carousel, lane

**Card**:
One title's artwork in a Row or grid: a portrait poster or a landscape thumbnail.
_Avoid_: Tile, item, poster (when meaning the general concept)

**Focused**:
The Card (or menu item, or button) the remote's highlight is on. A Focused Card grows slightly.
_Avoid_: Hover, hovered, selected (selecting means pressing OK)

**Info Line**:
A single line under a grid that shows the Focused Card's name, year, type and Request Status. Used where there is no Hero.
_Avoid_: Caption, tooltip

**Trailer Preview**:
A title's trailer playing muted in the Hero after a Card has been Focused for a few seconds. It uses only trailer files stored on the server and stops when focus moves.
_Avoid_: Autoplay, preview video

**Continue Watching**:
Titles the user started but didn't finish. Selecting one resumes playback immediately.
_Avoid_: Resume list, in progress

**Next Up**:
The next unwatched episode of each show the user is following. Selecting one plays it immediately.
_Avoid_: Up next (that name belongs to the end-of-episode prompt)

**Up Next Prompt**:
The countdown panel near the end of an episode that offers to play the next one.
_Avoid_: Autoplay screen, next episode card

### Playback

**Track Picker**:
The panel during playback for choosing the audio track and subtitles.
_Avoid_: Language menu, options menu

### Finding things

**Search**:
The one place to look up a title by name. It shows a grid of matches from the library first, then titles that can be Requested under "Not in your library".
_Avoid_: Discover search, request search

### Requests

**Seerr**:
The household's separate request app, which adds titles to the server when someone asks for them. Marquee's request features appear only when Seerr is found.
_Avoid_: Jellyseerr, Overseerr

**Request**:
Asking Seerr to add a title that isn't in the library yet. For a show, a Request covers all seasons unless the User picks specific ones.
_Avoid_: Download, add

**Discover**:
The main-menu screen showing trending and popular titles from Seerr, whether or not they're in the library.
_Avoid_: Explore, requests page

**Request Status**:
Where a Requested title stands: Requested, Downloading or Available. Shown as a badge on its Card.

### Signing in

**User**:
A Jellyfin account on the server. Each person in the household is a User.
_Avoid_: Profile, account

**Who's Watching**:
The screen listing the server's Users with their avatars, where the person watching picks themselves.
_Avoid_: Profile picker, user select

**Server Discovery**:
Finding Jellyfin servers on the home network automatically, so the user never types an address.
_Avoid_: Scan, auto-detect

**Quick Connect**:
Jellyfin's sign-in method where the TV shows a short code and the user approves it from another signed-in device.
_Avoid_: Pairing, device code
