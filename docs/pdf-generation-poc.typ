//
// Global formatting
//
#set page(
  footer: align(right, counter(page).display("1 / 1", both: true))
)
#set text(
  font: "Liberation Sans",
  size: 10pt
)
#set par(
  leading: 0.62em,
)
#let title(t) = text(
  size: 22pt,
  weight: "bold",
  t
);
#set list(body-indent: 10pt)
#show link: set text(blue)
#show heading: set block(above: 33pt, below: 15pt)
#show heading.where(level: 1): set text(size: 18pt)
#show table: set block(above: 20pt, below: 33pt)
#set table.cell(breakable: false)

#let frame(stroke) = (x, y) => (
  left: if x > 1 { 1pt } else { stroke },
  right: stroke,
  top: if y < 2 { stroke } else { 1pt },
  bottom: stroke,
)

#set table(
  fill: (x, y) => {
    if calc.odd(y) {
      rgb("EAF2F5")
    }
  },
  stroke: frame(rgb("bbb")),
)
#show table.cell: content => {
  if content.x == 0 {
    content
  }
  if content.x == 1 {
    set list(marker: text(fill: green, "+"), )
    content
  }
  if content.x == 2 {
    set list(marker: text(fill: red, "-"))
    content
  }
}

//
// Start of content
//
#title([PDF Generation Proof of Concept])

In support to the checking process of election results, Kiesraad would like to generate a PDF containing the results given some input. In this document, we'll explain our chosen solution and the considerations we made along the way. First we'll talk about the project's constraints and explaining certain solutions we considered, then we'll talk about the resulting implementation.

= Context

There are several different kinds of PDFs to be generated in different styles and layouts, ranging from about 10 to about 350 pages. The application will run on an air-gapped machine and the data running through the application should not be manipulated.
There will be around 340 installations and will be done by many different people.
Currently, Kiesraad depends on an external vendor for developing and changing the templates, which is a time consuming and error prone process.

With this, we can come up with the following constraints:

- it should work without a connection to the internet
- the total size of the application should be reasonable and fit on a memory stick
- it should run on GNU/Linux and Windows
- installation should be easy and fool-proof
- Kiesraad should be able to do template development

= Considered solutions

The following table contains the several software stacks we considered which each of their pros and cons.

#table(
  columns: 3,
  align: (x, _) => { if x == 0 { horizon } else { top } },
  inset: 8pt,
  table.header(
    [*Stack*], [*Pros*], [*Cons*]
  ),
  
  [*printpdf* \ #link("https://docs.rs/printpdf/latest/printpdf/")[docs.rs]],
  [
    - All the control you would ever want
    - Very few dependencies
  ],
  [
    - All the control you would ever want
    - Needs layout engine that can translate to printpdf
    - Needs additional templating solution
  ],

  [*HTML/CSS*],
  [
    - Well known by lots of developers
    - Screen based, not page based
    - Powerful styling options
  ],
  [
    - Very limited typesetting options
    - Needs a browser for rendering a PDF, i.e. lots of dependencies
  ],

  [*(La)TeX*] ,
  [
    - Well known, lots of resources
    - Lots of typesetting options
    - Stable and mature ecosystem
  ],
  [
    - Needs additional templating layer
    - Needs lots of small dependencies
    - Sensitive to the software environment it is running in
    - Errors are hard to understand
  ],
  
  [*Typst* \ #link("https://typst.app")[typst.app]],
  [
    - ‘All-in-one solution’: templating, layout and PDF generation
    - Written in Rust, which makes it easier for us to adopt
    - Templating language seems intuitive for people with a web based background
  ],
  [
    - New kid on the block. Although packed with all the features we need, it's still quite new.
  ],
)

== Chosen solution

We ended up chosing Typst as its pros far outweigh its cons in our opinion. The codebase (at the moment at least) seems well written, nicely structured and quite easily understandible.

Might there be a case where something is missing, broken, or wrong about Typst, there are certainly scenarios thinkable where we could fork and/or contribute back to the Typst repository.

= Overview of the PoC implementation results
In this section, we'll explore the results and considerations of the implementation we did for this Proof of Concept.
The repository is found on #link("https://github.com/kiesraad/rust-pdf-poc")[GitHub]. For technical details on running the implementation, see the #link("https://github.com/kiesraad/rust-pdf-poc/blob/main/README.md")[README].

== Stack/dependencies
Below are all used dependencies (crates), used for the Proof of Concept. Note that the reported versions are the versions used at the time of writing this document.

#table(
  columns: 3,
  inset: 9pt,
  [*Crate*],    [*Version*], [*Description*],
  [`chrono`],     [`0.4.35`],    [Used to feed `typst` with the current time and date],
  [`clap`],       [`4.5.4`],     [To provide the user with a nice command line interface],
  [`comemo`],     [`0.4.0`],     [Used for memoization of assets],
  [`serde`],      [`1.0.197`],   [Used for serializing],
  [`serde_json`], [`1.0.114`],   [Used for serializing and type checking the JSON input],
  [`typst`],      [`0.11`],      [Used for compiling the Typst documents],
  [`typst-pdf`],  [`0.11`],      [Used for PDF generation],
)

Aside from Rust code we created two Typst templates (see `templates/` in the GitHub repository), based on two provided examples. Each of these Typst templates shares common styles and scripts (see `templates/common/` in the GitHub repository).

Typst can use either online or offline vendored Typst code as external dependency. We tested this with the #link("https://github.com/PgBiel/typst-tablex")[`tablex`] dependency, but during the development of this Proof of Concept, Typst released new versions of their crates, which included most of the functionality we needed for tables, thus mitigating the need for an external dependency.

It is worth noting that using a lot of (external) Typst code can increase the compilation time of the templates dramatically. It is advised to use built-in functionality wherever possible, as it is written in Rust as doesn't need to be parsed and interpreted every time.

== Installation

Building the application is as simple as running:

```console
$ cargo build --release
```

The resulting binary will contain everything needed to generate the PDF, except the input JSON data. The binary can be transferred and used directly on the targeted device.

The size of a release build, containing 4 font variants, 3 templates files and the compiled program is about *34MB*. This will of course increase as more and bigger assets are added to the binary.

Might the binary size become a problem in the future, there are lots of optimizations we could do, such as compressing the assets with `gzip` or `brotli`. It would be best to solve this problem when it becomes one.

== Testing
There are several ways to test the Typst documents. The challenge here is mainly that Rust's PDF ecosystem is quite immature at this moment. These are the methods we either tried or considered:

=== 1. Testing via the `Document` interface of the `typst` crate
The `Document` interface contains the compiled Typst document before it is generated to PDF or PNG. Although this looked like a straight forward way for testing first, it seems that currently this struct is quite undocumented and lacks examples. During a brief experiment we weren't able to get a useful test running. Since Typst development is very much ongoing, this could change in the future.
It is also worth mentioning that this method only checks the `Document` struct before it is generated into a PDF, so errors in the conversion process wouldn't be catched.

=== 2. Reading the generated PDF content via the `lopdf` crate
The other method we tried is using #link("https://docs.rs/lopdf/latest/lopdf/")[lopdf]. This library unfortunately doesn't seem to understand Typst's PDF output though, as it gives a whole list of `Unimplemented?` strings when reading the PDF. \
Alternatively we could use external utilities like Poppler's `pdftotext`, although we haven't tried this yet. Potentially this could be useful to test for certain content, but with this method you would lose the document structure.

=== 3. Generate an image and check it pixel-by-pixel
We haven't experimented with this method, but in theory we could generate an image (either by generating a PNG with Typst, or converting the generated PDF to an image by something like Poppler's pdftoppm) and then apply some kind of smart diff. The downside to this method is that you can't test for specific components of the PDF and the tests are sensitive to the smallest of changes.

= Closing remarks

Although testing wasn't as straightforward as we initially thought, we are confident that the proposed solution is viable to create a production ready application. Building the application around Typst solved most problems around templates, layouts, styling and PDF generation, while keeping the needed dependencies reasonable.

With Typst being open source and written in Rust, forking the project could provide an escape hatch in the unfortunate situation when the project gets abandoned. At the moment, the Typst repository is very active and is getting a lot of attention, so it is very unlikely this will happen any time soon.

This document is written in Typst.
