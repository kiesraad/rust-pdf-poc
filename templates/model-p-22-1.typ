#import "common/style.typ": conf, title
#import "common/scripts.typ": input_date, input_digit
#let input = json("inputs/model-p-22-1.json")

#show: doc => conf(
  input,
  doc
)

#title(
  input.version,
  [Proces-verbaal van de uitslag van de verkiezing van de #input.leden_van],
  [De verkiezing van de leden van de *#input.leden_van* \ op *#input.datum*]
)

= Zitting; aantal kiesgerechtigden
Het betreft de openbare zitting van het centraal stembureau in *'s-Gravenhage*.
Datum en tijdstip aanvang zitting 1 december 2023 10:00 uur.
Het aantal kiesgerechtigden voor deze verkiezing bedraagt *12345678*.

= Verslag controlewerkzaamheden
Zie bijlage 2 bij dit proces-verbaal. 

= Ingeleverde kandidatenlijsten
De volgende politieke groeperingen hebben deelgenomen aan de verkiezing (in de volgende kieskringen): 

#pagebreak()

#table(
  align: bottom,
  columns: (
    40pt, 80pt, 22pt, 22pt, 22pt, auto, auto, auto, auto, auto,            
    auto, auto, auto, auto, auto, auto, auto, auto, auto, auto,
    auto, auto, auto, auto, auto,
  ),
  inset: 8pt,
  table.header(
    [*Lijstnr.*],
    [*Lijstnaam*],
    table.cell(
      colspan: 3,
      [*Ingeleverd*]
    ),
    table.cell(
      colspan: 20,
      [*Kieskring*]
    ),
    [],
    [],
    rotate(-90deg, reflow: true, [Lijstengroep \ (gelijkluidende lijsten)]),
    rotate(-90deg, reflow: true, [Lijstengroep \ (niet gelijkluidende lijsten)]),
    rotate(-90deg, reflow: true, [Op zichzelf staande lijst]),
    [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], 
    [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], 
  ),
  stroke: (
    left: 0pt,
    right: 0pt,
    top: 0.5pt,
    bottom: 0.5pt,
  ),
  ..for partij in input.partijen {
      (
        [#partij.positie],
        partij.naam,
        
        // Ingeleverd
        if partij.gelijkluidend { [\*] },
        if not partij.gelijkluidend { [\*] }, 
        [],
        
        // Kieskring
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],

        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
        [\*],
      )
    }
)

#pagebreak(weak: true)

= Aantal stemmen per lijst
#let table = {
  let fill = white
  // let fill = rgb("e4e5ea")

  let num_kieskringen = input.kieskringen.len()

  let batch_size = 9

  for batch_start in range(0, num_kieskringen, step: batch_size) {
    let batch_end = calc.min(batch_start + batch_size, num_kieskringen)
    let kieskring_nrs = range(batch_start, batch_end).map(n => input.kieskringen.at(n).number)
    let incl_totals = batch_end == num_kieskringen

    let columns = (auto, ..range(batch_start, batch_end).map(_ => 1fr))
    let align = (left, ..range(batch_start, batch_end).map(_ => end)).map(a => a + horizon)
    let header_one = ([], table.cell(align: start, colspan: batch_end - batch_start, [*Kieskring*]))
    let header_two = ([*Lijstnr.*], ..kieskring_nrs.map(n => [#n]))


    let kieskring_totals = kieskring_nrs.map(kieskring_heading => {
      let totals = input.kieskringen.find(k => k.number == kieskring_heading)
      ([#totals.total_stemmen], [#totals.blanco_stemmen], [#totals.ongeldige_stemmen])
    })

    let kieskring_total = kieskring_totals.map(t => t.at(0))
    let kieskring_blanco = kieskring_totals.map(t => t.at(1))
    let kieskring_ongeldig = kieskring_totals.map(t => t.at(2))

    if incl_totals {
      columns.push(auto)
      align.push(end)
      header_one.push([*Totaal*])
      header_two.push([])

      kieskring_total.push([#input.kieskringen.fold(0, (sum, k) => {sum + k.total_stemmen})])
      kieskring_blanco.push([#input.kieskringen.fold(0, (sum, k) => {sum + k.blanco_stemmen})])
      kieskring_ongeldig.push([#input.kieskringen.fold(0, (sum, k) => {sum + k.ongeldige_stemmen})])
    }

    table(
      columns: columns,
      fill: fill,
      align: align,
      stroke: none,
      table.header(
        ..header_one,
        ..header_two,
      ),
      table.hline(start: 0, end: batch_end - batch_start + 1),
    ..input.stemmen.map(partij => {
      let row = ([#partij.lijstnummer],
      kieskring_nrs.map(kieskring_heading => [
        #partij.kieskringen.find(k => k.number == kieskring_heading).votes
      ]))
      if incl_totals {
        row.push([#partij.kieskringen.fold(0, (sum, k) => {sum + k.votes})])
      }
      row
    }).flatten(),
    table.hline(),
    [*Totaal*],
    ..kieskring_total,
    table.hline(),
    [Blanco \ stemmen],
    table.hline(),
    ..kieskring_blanco,
    [Ongeldige \ stemmen],
    ..kieskring_ongeldig,
    table.hline(),
  )
  }

}

#table

// ..input.kieskringen.map(k => [*#k.number*])
