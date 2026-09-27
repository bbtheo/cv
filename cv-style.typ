// CV style for the Typst/PDF output. Shares the cover letter look (Source
// Serif 4 body, Source Sans 3 labels). Quarto shifts "##" to level 1
// (sections) and "###" to level 2 (entries). cv-columns and cv-meta are
// emitted by typst-layout.lua.

#let ink = rgb("#1c2430")
#let accent = rgb("#1f4e79")
#let muted = rgb("#6b7280")
#let rule = muted.lighten(55%)
#let serif = ("Source Serif 4",)
#let sans = ("Source Sans 3",)

#let contact-links = (
  link("tel:+358407181510")[+358 40 718 1510],
  link("mailto:theo.blauberg@outlook.com")[theo.blauberg\@outlook.com],
  link("https://github.com/bbtheo")[github.com/bbtheo],
  link("https://www.linkedin.com/in/theo-blauberg/")[linkedin.com/in/theo-blauberg],
)

// Replaces Quarto's article(); only the title is used.
#let article(title: none, doc, ..args) = {
  set page(
    paper: "a4",
    margin: (x: 1.9cm, top: 1.7cm, bottom: 1.8cm),
    numbering: none,
    footer: context {
      set text(font: sans, size: 8pt, fill: muted)
      [Theo Blauberg · Curriculum vitae]
      h(1fr)
      counter(page).display("1 / 1", both: true)
    },
  )
  set text(font: serif, size: 9.5pt, fill: ink, lang: "en", region: "GB",
           number-type: "old-style")
  set par(justify: false, leading: 0.6em, spacing: 0.85em)
  set list(indent: 0em, body-indent: 0.55em, spacing: 0.55em,
           marker: text(fill: muted)[–])
  show link: set text(fill: accent)
  show strong: set text(weight: "semibold")

  block(below: 1.1em, text(size: 26pt, weight: "semibold", tracking: -0.01em, title))
  {
    set text(font: sans, number-type: "lining")
    text(size: 9.5pt, weight: "medium", fill: muted, tracking: 0.06em,
      upper[Senior Analytics Engineer | M.Sc. Economics | M.Sc. Data Science (ongoing)])
    v(0.35em)
    set text(size: 9pt, fill: muted)
    contact-links.join(h(0.5em) + text(fill: muted.lighten(40%))[•] + h(0.5em))
  }
  v(0.2em)
  line(length: 100%, stroke: 0.5pt + rule)
  v(0.4em)
  doc
}

// Section headings
#show heading.where(level: 1): it => block(above: 1.5em, below: 0.75em, width: 100%, {
  set text(font: sans, size: 9.5pt, weight: "semibold", fill: accent,
           tracking: 0.08em, number-type: "lining")
  upper(it.body)
  v(-0.55em)
  line(length: 100%, stroke: 0.5pt + rule)
})

// Entry headings (job titles, degrees, projects)
#show heading.where(level: 2): it => block(above: 1.1em, below: 0.45em, sticky: true,
  text(size: 10pt, weight: "semibold", it.body))

// Organisation on the left, dates on the right
#let cv-meta(org, dates) = block(above: 0.45em, below: 0.6em, sticky: true, grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  align: (left + bottom, right + bottom),
  org,
  text(font: sans, size: 8.5pt, fill: muted, number-type: "lining", dates),
))

// Sidebar (first column) is set slightly smaller than the main column.
// Column tops carry no heading spacing, so the block adds it.
#let cv-columns(widths, ..cols) = block(above: 1.5em, grid(
  columns: widths,
  column-gutter: 1.4em,
  ..cols.pos().enumerate().map(((i, c)) => if i == 0 and cols.pos().len() > 1 {
    set text(size: 9pt)
    c
  } else { c }),
))
