# CV

`cv.qmd` renders to HTML (site, published to gh-pages by CI), docx, gfm, and Typst PDF (`docs/cv.pdf`).

## PDF layout

- `cv-style.typ` sets the PDF style: letterhead, fonts, section and entry headings. Fonts are bundled in `fonts/` (Source Serif 4, Source Sans 3; SIL OFL).
- `typst-layout.lua` (Typst only) maps the HTML layout divs to Typst: `.columns`/`.column` to `cv-columns` (a grid), `.aligned-text` to `cv-meta` (organisation left, dates right). Divs with `.pdf-hide` are dropped (the Contact column, which duplicates the letterhead).
- Quarto shifts headings: `##` is level 1 (section) and `###` is level 2 (entry) in the Typst output.

## Decisions

- 2026-09-27: PDF restyled to match the cover letters (`~/cover-letters/letter-style.typ`); change both together. The old PDF showed `###` headings as sections and lost the two-column layout.
