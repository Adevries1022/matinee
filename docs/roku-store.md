# Getting Matinee on the Roku Streaming Store

A working checklist for publishing Matinee as a free public app. It follows Roku's [certification criteria](https://developer.roku.com/dev/docs/certification) (last updated October 2026), the [deep linking](https://developer.roku.com/dev/docs/implementing-deep-linking) guide and the [manifest](https://developer.roku.com/dev/docs/channel-manifest) spec. Numbers like 4.9 are Roku's criteria numbers.

Matinee is a "Free" app in Roku's terms: no ads, no subscription, no purchases. That rules out the Roku Pay, advertising and Instant Signup criteria. The streaming-hour thresholds (Continue Watching, voice controls, Automatic Account Link) don't apply to a new small app either.

## Done

| Criterion | What Matinee does |
|---|---|
| 3.2 Launch within 15 s, with a beacon | Sends `AppLaunchComplete` when the first screen can take input (Home's Rows, Who's watching, the server picker) or when a deep link starts playing. Measured 3.6 s on the TCL 55R655. |
| 3.7 App under 4 MB | `matinee.zip` is about 0.8 MB. |
| 4.6 Back | Back returns to the previous screen; on Home it opens the Rail, then exits. |
| 4.10 Bookmarks | Jellyfin keeps resume points on the server, with no time limit. |
| 5.1 Deep linking | `contentId` is a Jellyfin item id. Movie, episode, tvSpecial and shortFormVideo play from the bookmark; series plays the next episode (the one in progress, the next unwatched, or S1E1); season opens Details on that season; anything unknown lands on Home with a Toast. Works at launch and, through `roInput`, while running. A deep link uses the last User without showing Who's watching. **Not yet tested on the TV** (Jellyfin was down). |
| Manifest | `rsg_version=1.3` (required since October 1, 2026), `supports_input_launch=1`, `mm_icon_focus_fhd` 540x405, `mm_icon_focus_hd` 290x218, a 1280x720 HD splash. `npm run brand` makes the images. |
| 6.4 Splash | FHD and HD splash screens, opaque, on the Midnight background. |
| 4.12 Voice keyboard | Typing uses Roku's `DynamicKeyboard` with voice entry, and the password keyboard for passwords and API keys. Checked on the TV. |
| 4.9 Instant replay | The replay button jumps back 10 seconds in the Player. |
| 4.8 Captions (partly) | The Player follows the Roku's captions setting, no longer switches it off, and keeps in step with captions turned on or off from Roku's * menu. Still to check: caption style and language settings, and On instant replay / On mute. |

## Still to do in the app

1. **4.8 Closed captions, the rest.** Test On instant replay and On mute from Roku's * menu with Jellyfin subtitle tracks, and whether the Roku's caption style settings apply to Matinee's subtitles.
2. **4.7 Trick play thumbnails** for anything over 15 minutes. Matinee shows Jellyfin's trickplay images when the server has made them. Reviewers' content will have them only if their server generates trickplay, so confirm the demo server below does.
3. **5.2 Direct to Play.** Voice commands such as "Play Better Call Saul on Matinee" arrive as deep links; test them once deep links work.
4. **2.2 On-device sign-in.** Sign-in must happen on the TV. Signing in with a username and password on the TV is fine. Quick Connect has you approve the sign-in in Jellyfin on another device, which may count as off-device sign-in. Ask Roku, or hide Quick Connect in the store build.
5. **3.1 to 3.6 on a slow Roku.** Roku measures launch, screen changes (3 s), key response (250 ms) and video start (8 s) on a Roku Streaming Stick+ (3810X) or Premiere+ (3921X). Test on one of those, or something as slow, before submitting.
6. **6.1 Version.** Bump `build_version` (or `minor_version`) for every build submitted.

## Reviewers need a server

Roku's App Behavior Analysis launches the app and expects to reach content. Matinee can't show anything without a Jellyfin server, so the submission needs:

- A server reviewers can reach from the internet, with a sign-in that works on the TV. Jellyfin runs a public demo server (demo.jellyfin.org) with a "demo" user, but it's shared and resets; a small server of our own with a few public-domain films is safer.
- Sample deep links (a `contentId` for a movie, an episode and a series) from that server's library, entered in the Developer Dashboard.
- Sign-in steps in the submission notes.

## Store listing and account (done by you, in the Developer Dashboard)

1. **Roku developer account** at developer.roku.com, with the developer agreement accepted.
2. **Signing key.** Packages for the store are signed with a key generated on a Roku (`genkey` over telnet port 8080). Keep the key and its password safe and out of the repo: every future update must be signed with the same key.
3. **Listing:** name, description and a 540x405 poster (`images/icon_fhd.png`) for each language. The name must not include "Roku". Don't make "Jellyfin" look like the publisher: "Matinee" with "for Jellyfin" in the description is safer.
4. **Contacts:** customer support URL, email and phone number, plus administrative and technical leads (name, email, phone with country code).
5. **Category** and content rating, then run Static Analysis and App Behavior Analysis in the dashboard, and schedule publishing.

A beta app (up to 120 days, installed with an access code, no certification) is a good way to let friends test the store build before submitting.
