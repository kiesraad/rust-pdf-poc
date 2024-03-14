//#import "vendor/tablex.typ": tablex, rowspanx, colspanx
#let input = json("input.json")

#set text(
  font: "Bitstream Vera Sans",
  size: 10pt
)
#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 1.5cm),
  numbering: "1 / 1",
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

#let input_digit() = {
  box(width: 14pt, height: 9pt)[
    #path(
      stroke: black,
      closed: false,
      (15%, 0%),
      (0%, 0%),
      (0%, 100%),
      (100%, 100%),
      (100%, 0%),
      (85%, 0%),
    )
  ]
}

#let input_date() = [
  #input_digit() #input_digit() - #input_digit() #input_digit() - #input_digit() #input_digit() #input_digit() #input_digit() (dd-mm-jjjj)
]

#show heading.where(level: 1): set text(size: 18pt)

#show heading.where(level: 3): set text(weight: "regular", size: 12pt)

=== Model O 7: Proces-verbaal van een hoofdstembureau

#line(length: 100%)

== Model O 7

= Proces-verbaal van een hoofdstembureau
De verkiezing van de leden van de *#input.leden_van*
#grid(
  columns: (100pt, auto),
  gutter: 5pt,
  [op],
  [*#input.datum*],
  [Kiesring],
  [*#input.kiesring*],
)

#line(length: 100%)

Met dit proces-verbaal stelt het hoofdstembureau voor een kieskring de uitkomst van de stemming bij de in deze kieskring gevestigde stembureaus vast voor de verkiezing van de leden van de Tweede Kamer der Staten-Generaal.

#block(stroke: black, inset: 10pt, width: 100%)[
  *Let op! Alleen in te vullen door het centraal stembureau, indien van toepassing*
  #grid(
    columns: (30pt, auto),
    gutter: 10pt,
    [#box(stroke: black, width: 9pt, height: 9pt)],
    [
      In opdracht van het centraal stembureau hebben een of meer gemeentelijk stembureaus de in dit proces-verbaal opgenomen aantallen (opnieuw) onderzocht. Deze blijken niet allemaal juist te zijn. Een of meer gemeentelijk stembureaus hebben in een nieuwe zitting de juiste aantallen vastgesteld. Als gevolg daarvan zijn er ook een of meer aanpassingen nodig in het proces-verbaal van het hoofdstembureau. Zie voor de correcties het corrigendum bij dit proces-verbaal.

      Het corrigendum is vastgesteld op: #input_date()
    ],
    [#box(stroke: black, width: 9pt, height: 9pt)],
    [
      Het centraal stembureau heeft de in dit proces-verbaal opgenomen aantallen onderzocht. Deze blijken niet allemaal juist zijn. Het centraal stembureau heeft de juiste aantallen vastgesteld. Zie voor de correcties het corrigendum bij dit proces-verbaal.

      Het corrigendum is vastgesteld op: #input_date()
    ]
  )
]

#show heading.where(level: 2): it => {
  block(width: 100%, fill: black, inset: 8pt, radius: 1pt)[
    #text(fill: white)[#it.body]
  ]
}

#show heading.where(level: 3): it => {
  text(weight: "bold", size: 12pt)[#it.body]
}

== Zitting: aantal kiesgerechtigden

== Aantal stemmen

=== Aantal geldige, blanco en ongeldige stemmen

=== Aantal stemmen per kandidaat en lijst
/*
#for lijst in input.stemmen {
  tablex(
    columns: (80pt, 1fr, auto),
    repeat-header: true,
    inset: 8pt,
    header-rows: 2,
    colspanx(3)[
      #grid(
        columns: (auto, auto),
        gutter: 12pt,
        [*Lijstnaam*],   [#lijst.naam],
        [*Lijstnummer*], [#lijst.lijstnummer],
      )
    ],
    [*Nummer op de lijst*], [*Naam kandidaat*], [*Aantal stemmen*],
    ..for kandidaat in lijst.kandidaten {
      (
        align(right)[#kandidaat.positie],
        kandidaat.name,
        align(right)[#kandidaat.votes],
      )
    }
  )
}
*/
