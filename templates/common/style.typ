#let conf(input, doc) = [
  #set text(
    font: "Bitstream Vera Sans",
    size: 9pt
  )
  #set page(
    paper: "a4",
    margin: (x: 1.8cm, y: 1.5cm),
    numbering: "1 / 1",
    header: {
     text([#input.version: Proces-verbaal van de uitslag van de verkiezing van de #input.leden_van])
     line(length: 100%)
    },
    footer: [
      #grid(
        columns: (1fr, 1fr),
        [Datum: #input.gen_datum],
        align(right)[
          pagina #counter(page).display("1 / 1", both: true)
        ]
      )
    ]
  )

  #show heading.where(level: 2): it => {
    block(width: 100%, fill: black, inset: 6pt)[
      #text(fill: white)[#it.body]
    ]
  }

  #doc
]
