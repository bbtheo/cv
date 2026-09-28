# CV

`cv.qmd` renders to HTML (site, published to gh-pages by CI), docx, gfm, and Typst PDF (`docs/cv.pdf`).

## PDF layout

- `cv-style.typ` sets the PDF style: letterhead, fonts, section and entry headings. Fonts are bundled in `fonts/` (IBM Plex Sans, IBM Plex Mono; SIL OFL). The woff2 files there are the HTML site's Darker Grotesque.
- `typst-layout.lua` (Typst only) maps the HTML layout divs to Typst: `.columns`/`.column` to `cv-columns` (a grid), `.aligned-text` to `cv-meta` (organisation left, dates right). Divs with `.pdf-hide` are dropped (the Contact column, which duplicates the letterhead).
- Quarto shifts headings: `##` is level 1 (section) and `###` is level 2 (entry) in the Typst output.

## Rendering and publishing

- CI (`.github/workflows/publish.yml`) renders and publishes to gh-pages on every push to `main`. Local edits are not live until committed and pushed. Check with `gh run list`.
- The public PDF is https://bbtheo.github.io/cv/cv.pdf (served with a 10-minute cache). `pdffonts` on it shows which style is live (IBM Plex = current).
- For a local PDF, run `quarto render cv.qmd --to typst`. A full `quarto render` also writes `docs/cv.html`, `docs/site_libs/`, root `site_libs/` and more; the repo does not track these, so delete them afterwards. `.quarto/xref/` is tracked and changes on every render; revert it.

## Typst gotchas

- Quarto passes only `title` (and TOC settings) to `article()` unless the YAML sets more. Page settings must be in `cv-style.typ`, which also sets `numbering: none` to override Quarto's own `#set page(numbering: "1")`.
- Do not name Typst parameters `left`/`right`; they shadow the alignment values (error "cannot add content and alignment").
- An included `.typ` file must not share a basename with a `.qmd` in the same folder; Quarto's intermediate `<name>.typ` overwrites it.

## Decisions

- 2026-09-27: PDF restyled to match the cover letters (`~/cover-letters/letter-style.typ`); change both together. The old PDF showed `###` headings as sections and lost the two-column layout.
- 2026-09-28: Restyle is PDF only. The HTML site keeps its own theme (Cosmo, Darker Grotesque); do not restyle it to match.
- 2026-09-28: PDF switched to style "S2" with the cover letters: IBM Plex Sans, Plex Mono section labels (`// SECTION`) and dates, navy rail on the left edge, `›` bullets.
