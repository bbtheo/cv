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
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => article(
  title: [Theo Blauberg],
  toc_title: [Table of contents],
  toc_depth: 3,
  doc,
)

= Profile
<profile>
Senior Analytics Engineer with an advanced degree in Economics and extensive experience in econometrics, machine learning, and experimentation. Currently completing a Master's in Data Science at the University of Helsinki. Proficient in R, Python, SQL, and GPU computing. Experienced in building production ML models, interactive data applications, and internal analytics tooling.

#cv-columns((30fr, 70fr), [
= Education
<education>
== Master's Program in Data Science
<masters-program-in-data-science>
#strong[University of Helsinki] \
09/2021 - \

- #strong[Major:] Data Science
- Specializing in machine learning methods with emphasis on GPU-accelerated computing.
- #link("https://github.com/bbtheo/ds-thesis")[#strong[Thesis:]] Applying tabular foundation models to the detection of fraud patterns in high-dimensional transaction data. Work in progress; #link("https://bbtheo.github.io/ds-thesis/")[current draft].

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
#strong[Methods:] causal inference, RCT analysis, time-series econometrics \
#strong[ML/AI:] Torch, tidymodels, scikit-learn, Claude Agent SDK, Anthropic Python SDK, Chatlas \
#strong[Data:] dplyr, DuckDB, pandas, Arrow, Spark, Hive, Impala, Snowflake \
#strong[GPU:] CUDA Python, RAPIDS cuDF \
#strong[Engineering:] Docker, GitHub Actions, pytest, testthat \
#strong[Web:] Shiny, Quarto, PowerBI, REST APIs \

= Certifications
<certifications>
- #strong[NVIDIA:] Fundamentals of Deep Learning
- #strong[NVIDIA:] Fundamentals of Accelerated Computing with CUDA Python

], [
= Work Experience
<work-experience>
== Senior Analytics Engineer
<senior-analytics-engineer>
#cv-meta([
#strong[Nordea]

], [
07/2025 -

])
- Build, maintain, and monitor machine learning models that deliver real-time fraud detection for card and account-to-account transactions.
- Lead analytics initiatives with increased autonomy in model development and deployment decisions.
- Maintain an internal R package for data analysis and visualization, significantly improving team productivity.

== Data Analyst
<data-analyst>
#cv-meta([
#strong[Nordea]

], [
07/2023 - 07/2025

])
- Collaborated within a team responsible for building and monitoring real-time fraud detection models.
- Developed internal R packages, Shiny apps, and automated reports. Established a Data & Analytics community within the department.

== Data Analyst
<data-analyst-1>
#cv-meta([
#strong[VATT Institute for Economic Research]

], [
01/2023 - 06/2023

])
- Conducted analyses and co-authored research reports on electricity market data, focusing on #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:2tRrZ1ZAMYUC")[consumer] and #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:sJsF-0ZLhtgC")[company] responses to price shocks.
- Designed and developed a #link("https://github.com/datahuone/shiny_app")[Shiny-based dashboard] for interactive data visualization.

== Research Assistant
<research-assistant>
#cv-meta([
#strong[VATT Institute for Economic Research]

], [
08/2022 - 01/2023

])
- Supported research projects with data preparation, analysis, and visualization tasks.

== Project Worker
<project-worker>
#cv-meta([
#strong[City of Tampere]

], [
05/2022 - 08/2022

])
- Analysed a randomised controlled experiment (\~5,000 users) testing whether information nudges could shift mobility behaviour, as part of the Keli project (Kestävämmän liikkumisen kehittäminen hiilijalanjälkilaskurin avulla).
- Project co-funded by the Ministry of the Environment. Results published in a #link("https://scholar.google.fi/citations?view_op=view_citation&hl=en&user=19yd6u0AAAAJ&sortby=pubdate&citation_for_view=19yd6u0AAAAJ:NyGDZy8z5eUC")[working paper].

== Intern
<intern>
#cv-meta([
#strong[Embassy of Finland in Vienna]

], [
05/2021 - 08/2021

])
- Monitored and reported on Austrian economic developments to inform Finnish Government policy decisions.
- Attended and reported on meetings with UN organizations and local politicians.

= Projects
<projects>
== Running Coach - Self-Hosted Training Planner
<running-coach---self-hosted-training-planner>
- Building a self-hosted running coach that ingests Apple Health data into a canonical activity and vitals schema, maintains fitness and injury-load ledgers, and generates weekly plans from a deterministic guardrail engine.
- A Claude Agent SDK reviewer proposes plan changes that are validated against the guardrails before application. Python, FastAPI, SQLite, Docker; deployed on a home server behind Tailscale with pytest coverage across the engine.

== cuplyr - GPU-Accelerated dplyr
<cuplyr---gpu-accelerated-dplyr>
- Developing an R package that enables standard dplyr code to execute on GPU hardware through a RAPIDS cuDF backend.
- Implements lazy evaluation with automatic query optimizations. Benchmarks show 40-77x speedups over dplyr on GPU-resident data; parity end-to-end including transfer.
- #link("https://github.com/bbtheo/cuplyr")[GitHub]

== digitraffic - Fintraffic API Client
<digitraffic---fintraffic-api-client>
- Building an R package for Finland's Digitraffic road traffic sensor time series: 450+ roadside sensors, per-vehicle records, real-time and historical.
- Features tidyverse-native output, spatial filtering, built-in caching, and rate limiting. Tested with GitHub Actions; to be submitted to CRAN.
- #link("https://github.com/bbtheo/digitraffic")[GitHub]

== bracketeer - Tournament Management Framework
<bracketeer---tournament-management-framework>
- Developed an R package for modeling and executing tournament competitions with support for multiple formats including round-robin, Swiss system, and elimination brackets.
- Features a pipe-first API design for defining reusable tournament blueprints with automatic stage materialization and flexible result entry.
- #link("https://github.com/bbtheo/bracketeer")[GitHub]

== Reseptor - Recipe Assistant
<reseptor---recipe-assistant>
- #link("https://github.com/bbtheo/reseptor")[Python Shiny app] for interactive recipe creation on the Claude API via Chatlas.

= Positions of Responsibility
<positions-of-responsibility>
== Vote Counter - UNIDO
<vote-counter---unido>
Authorized by the Western countries group to serve as vote counter in the Secretary-General Election of the United Nations Industrial Development Organization.

== Board Member - Economics Students' Association
<board-member---economics-students-association>
Served on the board contributing to strategic planning and student activities.

])



