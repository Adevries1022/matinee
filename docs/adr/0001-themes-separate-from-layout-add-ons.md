# Themes control the look; Layout Add-ons control layout

A Theme only sets visual style: colors, Accent, corner rounding, type and Card styling. Changes to layout, such as Big Hero and Mini Cards, are separate Layout Add-ons that can be combined with any Theme and with each other. We chose this over bundling layout into each Theme, as many Steam Deck themes do, so the user can mix and match. It also keeps the number of combinations we have to make look right manageable: every Theme has to work with every Add-on, but no Theme has to reimplement a layout.

## Consequences

- Every Theme must look right under every combination of Layout Add-ons. Adding a Theme means checking it against each Add-on, not designing a new layout.
- Settings belong to each User, so two Users on the same TV can have different Themes and Add-ons.
