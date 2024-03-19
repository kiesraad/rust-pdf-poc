#import "common/style.typ": conf
#import "common/scripts.typ": input_date, input_digit
#let input = json("inputs/model-p-22-1.json")

#show: doc => conf(
  input,
  doc
)

*#input.version*

= Proces-verbaal van de uitslag van de verkiezing van de #input.leden_van
De verkiezing van de leden van de *#input.leden_van* op *#input.datum*

== 1. Zitting; aantal kiesgerechtigden
Het betreft de openbare zitting van het centraal stembureau in *'s-Gravenhage*.
Datum en tijdstip aanvang zitting 1 december 2023 10:00 uur.
Het aantal kiesgerechtigden voor deze verkiezing bedraagt *12345678*.

== 2. Verslag controlewerkzaamheden
Zie bijlage 2 bij dit proces-verbaal.

== 3. Ingeleverde kandidatenlijsten
De volgende politieke groeperingen hebben deelgenomen aan de verkiezing (in de volgende kieskringen):

#table(
  columns: (
    40pt, 80pt, 42pt, 42pt, 22pt, auto, auto, auto, auto, auto,            
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
    [#rotate(-90deg, reflow: true, [Lijstengroep (gelijkluidende lijsten)])],
    [#rotate(-90deg, reflow: true, [Lijstengroep (niet gelijkluidende lijsten)])],
    [#rotate(-90deg, reflow: true, [Op zichzelf staande lijst])],
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
        [\*],
        [\*],
        [\*],
        
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
