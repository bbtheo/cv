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
