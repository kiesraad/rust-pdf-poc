# Kiesraad Rust PDF generation

A Proof of Concept application that generates a PDF given a `model` consisting of a Typst template and some JSON `input`.

## Usage

### Development

Typst template development can be done in several ways. Via the `typst-cli`, The [online Typst editor](https://typst.app/), or via this Rust program by running:

```console
$ cargo watch -x run
```

To develop Typst in your editor of choice, there is a [Typst language server](https://github.com/nvarner/typst-lsp) available and a [Tree-sitter grammar](https://github.com/uben0/tree-sitter-typst).

### Packaging

This Proof of Concept tries to make installation as easy as possible by embedding all assets in the binary. When running or building in release mode (`cargo build --release`), all Typst files and fonts are embedded into the binary and used from memory when running the application.
