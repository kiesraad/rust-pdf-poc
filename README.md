# Kiesraad Rust PDF generation

A Proof of Concept application that generates a PDF given a `model` consisting of a Typst template and some JSON `input`.

Copyright © 2024 Kiesraad. Licensed under the EUPL-1.2 or later.

## Usage

### Development

Typst template development can be done in several ways. Via the `typst-cli`, The [online Typst editor](https://typst.app/), or via this Rust program.

Here is an example command for running the Model O 7 template:
```console
$ cargo watch -x "run -- model-o-7 templates/inputs/model-o-7.json"
```

This will restart the program every time it detects a change in the source or template files. Since in development the template files are _not_ stored in the binary, recompilation is not needed when only the template files are changed, which will speed up the restart time of the program.

To develop Typst in your editor of choice, there is a [Typst language server](https://github.com/nvarner/typst-lsp) available and a [Tree-sitter grammar](https://github.com/uben0/tree-sitter-typst).

#### Fonts

When using the Rust application, the fonts will be available via the binary and no further configuration will be needed. For the CLI, you need to point to the fonts folder via `typst compile --font-path path/to/font`

#### Input data

The data used to render the templates should be provided in JSON format. When the provided JSON is in the wrong format, `serde-json` will throw an error.
When introducing a new field, you should add it to the according `PdfModel` enum variant, so it will be type-checked.

### Packaging

This Proof of Concept tries to make installation as easy as possible by embedding all assets in the binary. When running or building in release mode with `cargo build --release`, all Typst files and fonts are embedded into the binary and used from memory when running the application.
