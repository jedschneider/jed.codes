# AGENTS.md

Guidance for AI agents working in the jed.codes Hugo site.

## Design System Customization

Site-specific styling lives in `static/css/custom.css` (always loaded, after the
vendored `themes/hugo-ink` CSS). Don't edit files under `themes/` — override in
`custom.css` instead. Raw HTML in Markdown is enabled via
`markup.goldmark.renderer.unsafe = true` in `config.toml`.

Note: inside a raw HTML block, Goldmark does **not** process Markdown, so use
`<em>`/`<strong>` rather than `*...*` for emphasis within these tags.

### Aside callouts (`<aside>`)

Tinted callout panel for a "by the way" note, distinct from blockquotes
(which are serif italic). Usage in post Markdown:

```html
<aside data-label="Warning">
    <p>Body text. Use <em>em</em>/<strong>strong</strong>, not Markdown, in here.</p>
</aside>
```

Properties:

- **`data-label`** — optional. Sets the uppercase eyebrow label text. Omitted →
  defaults to `ASIDE`. Any free-form string works (e.g. `Gotcha`); the CSS
  uppercases it via `text-transform`.
- **Color variant** — driven by `data-label` value, case-insensitive. A
  constrained, semantic palette; unrecognized labels keep the default indigo:

  | `data-label` | Color  | Use for                  | CSS var             |
  |--------------|--------|--------------------------|---------------------|
  | (none/other) | indigo | general note             | `--callout-note`    |
  | `Tip`        | green  | advice, shortcuts        | `--callout-tip`     |
  | `Warning`    | amber  | caution, footguns        | `--callout-warning` |
  | `Security`   | red    | security / danger        | `--callout-security`|

Implementation notes (`custom.css`):

- Palette vars are declared in `:root`; each is dark enough for AA label
  contrast on white.
- A per-aside `--callout` local var holds the active accent; the panel tint (5%)
  and border (22%) are derived from it with `color-mix()`, so the whole callout
  is one color family.
- **To add a variant:** add one `--callout-*` var in `:root` and one
  `.post aside[data-label="X" i] { --callout: var(--callout-x); }` selector.
- Scoped to `.post` (the `<article class="post">` wrapper in
  `layouts/_default/single.html`).

### Table of contents (`.toc`)

Opt-in per post via front matter `toc: true`. Rendered as a collapsible
`<details class="toc">`. The aside label styling deliberately echoes this
block's uppercase-eyebrow idiom.

## Theme notes

- **Dark mode is not active.** `layouts/partials/header.html` only loads
  `themes/hugo-ink/static/css/dark.css` when `Params.mode` is `auto`/`dark`,
  and that param is unset in `config.toml`. Custom CSS targets the light theme
  only. If dark mode is enabled later, add dark variants (dark accent is
  `#9375fd`).
- Theme accent: `#3700ff`. Body font: Inter. Headings: Playfair Display.

## Local preview

```bash
hugo server -D   # -D includes drafts
```
