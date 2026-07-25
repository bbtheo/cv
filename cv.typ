// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}




#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (bottom: 1.5cm,left: 2cm,right: 2cm,top: 2.2cm,),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [Theo Blauberg],
  font: ("Libertinus Serif",),
  fontsize: 10pt,
  heading-family: ("Libertinus Serif",),
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)
// Page setup with contact header on every page
#let accent = rgb("#2563eb")

#set page(
  header: {
    set text(9pt)
    grid(
      columns: (1fr, auto),
      align: (left, right),
      [
        #text(size: 14pt, weight: "bold", fill: rgb("#111827"))[Theo Blauberg]
      ],
      [
        #text(fill: rgb("#4b5563"))[+358407181510]
        #h(0.8em)
        #text(fill: rgb("#9ca3af"))[|]
        #h(0.8em)
        #link("mailto:theo.blauberg@outlook.com")[theo.blauberg\@outlook.com]
        #h(0.8em)
        #text(fill: rgb("#9ca3af"))[|]
        #h(0.8em)
        #link("https://github.com/bbtheo")[GitHub]
        #h(0.8em)
        #text(fill: rgb("#9ca3af"))[|]
        #h(0.8em)
        #link("https://www.linkedin.com/in/theo-blauberg/")[LinkedIn]
      ]
    )
    v(0.3em)
    line(length: 100%, stroke: 1pt + accent)
  },
  footer: context {
    if counter(page).get().first() > 1 {
      set text(8pt, fill: rgb("#9ca3af"))
      h(1fr)
      [Page #counter(page).display()]
    }
  }
)

#block[
#block[
== Profile
<profile>
Senior Analytics Engineer with an advanced degree in Economics and extensive experience in econometrics, machine learning, and experimentation. Currently completing a Master's in Data Science at the University of Helsinki. Proficient in R, Python, SQL, and GPU computing. Experienced in building production ML models, interactive data applications, and internal analytics tooling.

]
#block[
== Contact
<contact>
\+358407181510
theo.blauberg\@outlook.com
#link("https://github.com/bbtheo")[Github]
#link("https://www.linkedin.com/in/theo-blauberg/")[Linkedin]
]
]
#block[
#block[
= Education
<education>
== Master's Program in Data Science
<masters-program-in-data-science>
#strong[University of Helsinki] \
09/2021 - \

- #strong[Major:] Data Science
- Specializing in machine learning methods with emphasis on GPU-accelerated computing.
- #link("https://github.com/bbtheo/ds-thesis")[#strong[Thesis:]] Applying tabular foundation models to the detection of fraud patterns in high-dimensional transaction data.

== Master's Program in Economics
<masters-program-in-economics>
#strong[University of Helsinki] \
09/2020 - 12/2022 \

- #strong[Major:] Economics
- #strong[Minors:] Statistics, Mathematics, Computer Science
- #link("https://github.com/bbtheo/gradu/blob/main/docs/bookdown-thesis.pdf")[#strong[Master's Thesis:]] Impact of Policy Shocks in the EU Emissions Trading System on Finland.

== Exchange Program
<exchange-program>
#strong[Fudan University, Shanghai] \
09/2018 - 06/2019 \
Studied Chinese language, politics, and economics, with focus on East Asian economic development.

== Language Course
<language-course>
#strong[University of Vienna] \
09/2015 - 12/2015 \
Intensive German language studies.

= Technical Skills
<technical-skills>
#strong[Languages:] R, Python, SQL, Julia, C++ \
#strong[ML/AI:] Torch, tidymodels, scikit-learn, LLMs \
#strong[Data:] dplyr, DuckDB, pandas, Arrow \
#strong[Web:] Shiny, Quarto, PowerBI, REST APIs \

= Certifications
<certifications>
- #strong[NVIDIA:] Fundamentals of Deep Learning
- #strong[NVIDIA:] Fundamentals of Accelerated Computing with CUDA Python
- #strong[DataCamp:] Deep Learning in Python
- #strong[DataCamp:] Data Scientist with R

]
#block[
= Work Experience
<work-experience>
== Senior Analytics Engineer
<senior-analytics-engineer>
#block[
#block[
#strong[Nordea]

]
#block[
07/2025 -

]
]
- Build, maintain, and monitor machine learning models that deliver real-time fraud detection for card and account-to-account transactions.
- Lead analytics initiatives with increased autonomy in model development and deployment decisions.
- Maintain an internal R package for data analysis and visualization, significantly improving team productivity.

== Data Analyst
<data-analyst>
#block[
#block[
#strong[Nordea]

]
#block[
07/2023 - 07/2025

]
]
- Collaborated within a team responsible for building and monitoring real-time fraud detection models.
- Developed internal R packages, Shiny apps, and automated reports. Established a Data & Analytics community within the department.

== Data Analyst
<data-analyst-1>
#block[
#block[
#strong[VATT Institute for Economic Research]

]
#block[
01/2023 - 06/2023

]
]
- Conducted analyses and co-authored research reports on electricity market data, focusing on #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:2tRrZ1ZAMYUC")[consumer] and #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:sJsF-0ZLhtgC")[company] responses to price shocks.
- Designed and developed a #link("https://github.com/datahuone/shiny_app")[Shiny-based dashboard] for interactive data visualization.

== Research Assistant
<research-assistant>
#block[
#block[
#strong[VATT Institute for Economic Research]

]
#block[
08/2022 - 01/2023

]
]
- Supported research projects with data preparation, analysis, and visualization tasks.

== Project Worker
<project-worker>
#block[
#block[
#strong[City of Tampere]

]
#block[
05/2022 - 08/2022

]
]
- Analysed a randomised controlled experiment (\~5,000 users) testing whether information nudges could shift mobility behaviour, as part of the Keli project (Kestävämmän liikkumisen kehittäminen hiilijalanjälkilaskurin avulla).
- Project co-funded by the Ministry of the Environment. Results published in a #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:NyGDZy8z5eUC")[working paper].

== Intern
<intern>
#block[
#block[
#strong[Embassy of Finland in Vienna]

]
#block[
05/2021 - 08/2021

]
]
- Monitored and reported on Austrian economic developments to inform Finnish Government policy decisions.
- Attended and reported on meetings with UN organizations and local politicians.

= Projects
<projects>
== cuplyr - GPU-Accelerated dplyr
<cuplyr---gpu-accelerated-dplyr>
- Developing an R package that enables standard dplyr code to execute on GPU hardware through a RAPIDS cuDF backend.
- Implements lazy evaluation with automatic query optimizations, achieving 40-77x speedups over dplyr on large datasets.
- #link("https://github.com/bbtheo/cuplyr")[GitHub]

== bracketeer - Tournament Management Framework
<bracketeer---tournament-management-framework>
- Developed an R package for modeling and executing tournament competitions with support for multiple formats including round-robin, Swiss system, and elimination brackets.
- Features a pipe-first API design for defining reusable tournament blueprints with automatic stage materialization and flexible result entry.
- #link("https://github.com/bbtheo/bracketeer")[GitHub]

== digitraffic - Finntraffic API Client
<digitraffic---finntraffic-api-client>
- Building an R package that provides tidy access to Finland's Digitraffic road traffic API, covering 450+ measurement stations with real-time speed, volume, and classification data.
- Features tidyverse-native output, spatial filtering, built-in caching, and rate limiting. To be submitted to CRAN.
- #link("https://github.com/bbtheo/digitraffic")[GitHub]

== Reseptor - AI Recipe Assistant
<reseptor---ai-recipe-assistant>
- Built a web application for interactive recipe creation using Python Shiny and Claude API integration via Chatlas.
- Features markdown output for easy recipe sharing and distribution.
- #link("https://github.com/bbtheo/reseptor")[GitHub]

== Petanque Liga
<petanque-liga>
- Built a #link("https://theoblauberg.shinyapps.io/petanque_liga/")[tournament management website] with automatic match scheduling and result tracking.
- Backend powered by Google Sheets for multi-device data entry.

== ImagesToAscii.jl
<imagestoascii.jl>
- Developing a #link("https://github.com/bbtheo/ImagesToAscii.jl")[Julia package] for converting images to ASCII art, exploring matrix operations and image processing.

= Positions of Responsibility
<positions-of-responsibility>
== Vote Counter - UNIDO
<vote-counter---unido>
Authorized by the Western countries group to serve as vote counter in the Secretary-General Election of the United Nations Industrial Development Organization.

== Board Member - Economics Students' Association
<board-member---economics-students-association>
Served on the board contributing to strategic planning and student activities.

]
]



