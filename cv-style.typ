// CV style for the Typst/PDF output, matching the cover letters ("S2"):
// IBM Plex Sans body, Plex Mono for contact line, section labels and dates,
// navy rail on the left edge. Quarto shifts "##" to level 1 (sections) and
// "###" to level 2 (entries). cv-columns and cv-meta are emitted by
// typst-layout.lua.

#let navy = rgb("#1f4e79")
#let ink = rgb("#1b2330")
#let muted = rgb("#667085")
#let sans = "IBM Plex Sans"
#let mono = "IBM Plex Mono"

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
    margin: (left: 2.1cm, right: 1.8cm, top: 1.7cm, bottom: 1.8cm),
    numbering: none,
    background: place(top + left, rect(width: 0.35cm, height: 100%, fill: navy)),
    footer: context {
      set text(font: mono, size: 7pt, fill: muted)
      [theo blauberg / cv]
      h(1fr)
      counter(page).display("1/1", both: true)
    },
  )
  set text(font: sans, size: 8.8pt, fill: ink, lang: "en", region: "GB")
  set par(justify: false, leading: 0.75em, spacing: 1.2em)
  set list(indent: 0em, body-indent: 0.6em, spacing: 0.6em, marker: text(fill: navy)[›])
  show link: set text(fill: navy)
  show strong: set text(weight: "semibold")
  show "C++": box

  text(size: 24pt, weight: "semibold", tracking: -0.01em, title)
  v(0.15em)
  text(size: 10.5pt, weight: "medium", fill: navy)[Senior Analytics Engineer · M.Sc. Economics · M.Sc. Data Science (ongoing)]
  v(0.5em)
  {
    set text(font: mono, size: 7.8pt, fill: muted)
    show link: set text(fill: ink)
    contact-links.join(h(0.6em) + text(fill: navy)[/] + h(0.6em))
  }
  v(0.3em)
  line(length: 100%, stroke: 0.6pt + navy)
  doc
}

// Section headings
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.8em, sticky: true,
  text(font: mono, size: 8.5pt, weight: "semibold", fill: navy, tracking: 0.04em,
    [\/\/ ] + upper(it.body)))

// Entry headings (job titles, degrees, projects)
#show heading.where(level: 2): it => block(above: 1.1em, below: 0.35em, sticky: true,
  text(size: 9.6pt, weight: "semibold", it.body))

// Organisation on the left, dates on the right
#let cv-meta(org, dates) = block(above: 0.35em, below: 0.6em, sticky: true, grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  align: (left + bottom, right + bottom),
  org,
  text(font: mono, size: 7.5pt, fill: navy, dates),
))

// Sidebar (first column) is set slightly smaller than the main column.
// Column tops carry no heading spacing, so the block adds it.
#let cv-columns(widths, ..cols) = block(above: 1.2em, grid(
  columns: widths,
  column-gutter: 1.6em,
  ..cols.pos().enumerate().map(((i, c)) => if i == 0 and cols.pos().len() > 1 {
    set text(size: 8.3pt)
    c
  } else { c }),
))
