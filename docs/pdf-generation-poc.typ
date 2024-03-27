#show link: set text(blue)

= PDF Generation Proof of Concept

In this document, we'll explain our choosen solution and the considerations we made along the way. First we'll explain certain solutions we considered, and then we'll talk about the resulting implementation.

== Considered solutions

The following table contains the several software stacks we considered wich each of their pros and cons.

#table(
  columns: 3,
  align: horizon,
  inset: 8pt,
  table.header(
    [*Stack*], [*Pros*], [*Cons*]
  ),
  
  table.cell(
    rowspan: 3,
    [*printpdf* \ #link("https://docs.rs/printpdf/latest/printpdf/")[docs.rs]]
  ), [All the control you would ever want], [All the control you would ever want],
  [Very few dependencies], [Needs layout engine that can translate to printpdf],
  [], [Needs additional templating solution],

  table.cell(
    rowspan: 3,
    [*HTML/CSS*]
  ), [Well known by lots of developers], [Screen based, not page based],
  [Powerful styling options], [Very limited typesetting options],
  [], [Needs a browser for rendering a PDF, i.e. lots of dependencies],
  
  table.cell(
    rowspan: 4,
    [*(La)TeX*]
  ), [Well known, lots of resources], [Needs additional templating layer],
  [Lots of typesetting options], [Needs lots of small dependencies],
  [Stable and mature ecosystem], [Sensitive to in which environment it is running],
  [], [Errors are hard to understand],
  
  table.cell(
    rowspan: 3,
    [*Typst* \ https://typst.app/]
  ), [‘All-in-one solution’: templating, layout and PDF generation], [New kid on the block. Although packed with all the features we need, it's still quite new.],
  [Written in Rust, which makes it easier for us to adopt], [],
  [Templating language seems intuitive for people with a web based background], [],
  
)

#pagebreak()

== Overview of the PoC implementation results
In this section, we'll explore the results and considerations of the implementation we did for this Proof of Concept.
The repository is found on #link("https://github.com/kiesraad/rust-pdf-poc")[GitHub]. For technical details on running the implementation, see the #link("https://github.com/kiesraad/rust-pdf-poc/blob/main/README.md")[README].

=== Stack/dependencies
Below are all used dependencies (crates), used for the Proof of Concept.

#table(
  columns: 3,
  [*Crate*],    [*Version*], [*Description*],
  [`chrono`],     [0.4.35],    [Used to feed `typst` with the current time and date],
  [`clap`],       [4.5.4],     [To provide the user with a nice command line interface],
  [`comemo`],     [0.4.0],     [Used for memoization of assets],
  [`serde`],      [1.0.197],   [Used for serializing],
  [`serde_json`], [1.0.114],   [Used for serializing and typechecking JSON],
  [`typst`],      [0.11],      [Used for compiling the Typst documents],
  [`typst-pdf`],  [0.11],      [Used for PDF generation],
)

Aside from Rust code we created two Typst templates (see `templates/` in the GitHub repository), based on two provided examples. Each of these Typst templates shares common styles and scripts (see `templates/common/` in the GitHub repository).

Typst can use either online or offline vendored Typst code as external dependency. We tested this with the #link("")[`tablex`] dependency, but during the development of this Proof of Concept, Typst released new versions of their crates, which included most of the functionality we needed for tables, thus mitigating the need for an external dependency.

It is worth noting that using a lot of (external) Typst code can increase the compilation time of the templates dramatically. It is advised to use built-in functionality wherever possible, as it is written in Rust as doesn't need to be parsed and interpreted every time.

=== Installation

Building the application is as simple as running:

```console
$ cargo build --release
```

The resulting binary will contain everything needed to generate the PDF, except the input JSON data. The binary can be transferred and used directly on the targeted device.

=== Testing
There are several ways to test the Typst documents. These are the methods we either tried or considered:

==== 1. Testing via the `Document` interface of the `typst` crate
The `Document` interface contains the compiled Typst document before it is generated to PDF or PNG. Although this looked like a straight forward way for testing first, it seems that currently this struct is quite undocumented and lacks examples. During a brief experiment we weren't able to get a useful test running.
It is also worth mentioning that this method only checks the `Document` struct before it is generated into a PDF, so errors it the conversion process won't be catched.

==== 2. Reading the generated PDF content via the `lopdf` crate
The other method we tried is using #link("https://docs.rs/lopdf/latest/lopdf/")[lopdf]. This library unfortunately doesn't seem to understand Typst's PDF output though, as it gives a whole list of `Unimplemented?` strings when reading the PDF. \
Alternatively we could use external utilities like Poppler's `pdftotext`, although we haven't tried this yet. Potentially this could be useful to test for certain content, but with this method you would lose the document structure.

==== 3. Generate an image and check it pixel-by-pixel
Although we haven't experimented with this method, we could generate an image (either by generating a PNG with Typst, or converting the generated PDF to an image by something like Poppler's pdftoppm) and then apply some kind smart diff. The downside to this method is that you can't test for specific components of the PDF and the tests are sensitive to the smallest of changes.
