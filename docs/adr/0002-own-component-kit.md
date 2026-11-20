# Build our own Theme-driven component kit instead of using a Roku UI framework

Roku can't run web UI libraries such as shadcn, so the UI is made from SceneGraph. We'll build a small set of our own components (Button, Card, Side Rail, Panel, Toggle) that take every color, rounding and font decision from the active Theme.

## Considered Options

- **SGDEX (Roku's own ready-made screens):** rejected because it produces the stock Roku look Marquee is trying to escape, and its styling hooks don't extend to Themes.
- **Kopytko (DAZN's declarative framework):** rejected for now. It changes how components are written, not how they look, and adds a dependency and a second programming model for a small app.
