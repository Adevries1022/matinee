---
status: accepted
---

# Draw our own Player OSD instead of using Roku's trickplay bar

The Player turns off the Roku Video node's own controls and draws Matinee's Player OSD. The design calls for a header, an Up Next Card, and track and next-episode controls in the Theme's look, which Roku's bar can't provide by changing its colors. In exchange, Matinee owns every playback key and everything drawn over the video.

## Considered Options

- **Roku's trickplay bar in the Accent:** less code and familiar from other channels, but it can't have the designed layout or buttons.

## Consequences

- Seeking, pause, hiding the controls, track choice and the Up Next Prompt are ours to maintain. They have to be checked on a real TV with real video, which screenshots don't capture.
- The seek bar has no buffered range, because the Video node doesn't report one.
- Anything Roku's own controls would have provided, such as thumbnails while seeking, is missing until we build it.
