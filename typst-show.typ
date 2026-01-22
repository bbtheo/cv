// Modern CV styling rules
// Applied via #show rules

// Define accent color
#let accent = rgb("#2563eb")

// Override the pandoc article function to skip title rendering
// This prevents the empty first page caused by the title block
#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )
  set par(justify: true)
  set text(lang: lang, region: region, font: font, size: fontsize)
  set heading(numbering: sectionnumbering)
  // NOTE: Title block removed - contact info is in the page header
  if cols == 1 { doc } else { columns(cols, doc) }
}

// Title (# heading / document title) - hidden since it's in the page header
#show heading.where(level: 1): it => {
  // Don't render the title - it's in the page header
}

// Section headings (## in markdown)
#show heading.where(level: 2): it => {
  set text(size: 12pt, weight: "bold", fill: accent)
  block(
    width: 100%,
    below: 0.5em,
    above: 1em,
  )[
    #upper(it.body)
    #v(-0.3em)
    #line(length: 100%, stroke: 0.75pt + accent.lighten(40%))
  ]
}

// Subsection headings (### in markdown)
#show heading.where(level: 3): it => {
  set text(size: 10.5pt, weight: "semibold", fill: rgb("#374151"))
  block(below: 0.25em, above: 0.6em, it.body)
}

// Links styling
#show link: it => {
  set text(fill: accent)
  underline(offset: 2pt, stroke: 0.5pt + accent.lighten(50%), it)
}

// List styling
#set list(
  indent: 0.8em,
  body-indent: 0.4em,
  marker: text(fill: accent, size: 7pt)[#sym.bullet],
)

// Strong text
#show strong: it => {
  text(weight: "semibold", it.body)
}

// Paragraph spacing - increased leading for better readability
#set par(justify: true, leading: 0.75em)

// Block quotes (if any)
#show quote: it => {
  set text(style: "italic", fill: rgb("#4b5563"))
  block(
    inset: (left: 1em),
    stroke: (left: 2pt + accent.lighten(70%)),
    it.body
  )
}
