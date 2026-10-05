# Font assets

The theme is designed around the typography already used in the Bilbao deck:

- **Manrope** — body text, secondary headings, section-transition titles, cover metadata.
- **IBM Plex Serif** — technical slide `h2` titles and the default thesis title on the cover.
- **IBM Plex Mono** — code.

The package does **not** contain font binaries. By default it uses these family names and falls back to local system fonts if they are not installed.

See `FONT_SETUP.md` in the project root for the two supported loading profiles:

1. online Google Fonts during development;
2. local self-hosted WOFF2 files for the final offline defense.
