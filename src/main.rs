use chrono::Datelike;
use comemo::Prehashed;
use std::{
    io::Write,
    process::{Command, Stdio},
};
use typst_pdf;
use typst::{
    self,
    diag::{FileResult, eco_format, FileError},
    foundations::{Bytes, Datetime, Smart},
    syntax::{FileId, Source, VirtualPath},
    text::{Font, FontBook, FontInfo},
    Library, World, eval::Tracer,
};


const DOC: &str = include_str!("../doc.typ");
const INPUT: &str = include_str!("../input.json");
const TABLEX: &str = include_str!("../vendor/tablex.typ");
const FONT: &[u8] = include_bytes!("../vendor/fonts/Vera.ttf");

struct MyWorld {
    source: Source,
    library: Prehashed<Library>,
    book: Prehashed<FontBook>,
}

impl World for MyWorld {
    #[doc = " The standard library."]
    #[doc = ""]
    #[doc = " Can be created through `Library::build()`."]
    fn library(&self) -> &Prehashed<Library> {
        &self.library
    }

    #[doc = " Metadata about all known fonts."]
    fn book(&self) -> &Prehashed<FontBook> {
        &self.book
    }

    #[doc = " Access the main source file."]
    fn main(&self) -> Source {
        self.source.to_owned()
    }

    #[doc = " Try to access the specified source file."]
    fn source(&self, _id: FileId) -> FileResult<Source> {
        FileResult::Ok(self.source.to_owned())
    }

    #[doc = " Try to access the specified file."]
    fn file(&self, id: FileId) -> FileResult<Bytes> {
        dbg!(id);
        // TODO: Actually implement this!
        if *id.vpath() == VirtualPath::new("/input.json") {
            FileResult::Ok(Bytes::from(INPUT.as_bytes()))
        } else if *id.vpath() == VirtualPath::new("/vendor/tablex.typ") {
            FileResult::Ok(Bytes::from(TABLEX.as_bytes()))
        } else {
            // TODO: Actually report a useful error
            FileResult::Err(FileError::NotSource)
        }
    }

    #[doc = " Try to access the font with the given index in the font book."]
    fn font(&self, index: usize) -> Option<Font> {
        Font::new(Bytes::from_static(FONT), index as u32)
    }

    #[doc = " Get the current date."]
    #[doc = ""]
    #[doc = " If no offset is specified, the local date should be chosen. Otherwise,"]
    #[doc = " the UTC date should be chosen with the corresponding offset in hours."]
    #[doc = ""]
    #[doc = " If this function returns `None`, Typst\'s `datetime` function will"]
    #[doc = " return an error."]
    fn today(&self, offset: Option<i64>) -> Option<Datetime> {
        let now = chrono::Local::now();

        let naive = match offset {
            None => now.naive_local(),
            Some(o) => now.naive_utc() + chrono::Duration::try_hours(o)?,
        };

        Datetime::from_ymd(
            naive.year(),
            naive.month().try_into().ok()?,
            naive.day().try_into().ok()?,
        )
    }
}

fn cli() {
    let mut child = Command::new("/home/marlonp/.cargo/bin/typst")
        .stdin(Stdio::piped())
        .arg("compile")
        .args(vec!["--font-path", "vendor/fonts"])
        .arg("-") // Indicates typst will read input from stdin
        .arg("doc.pdf") // Output file path
        .spawn()
        .expect("failed to execute process");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    std::thread::spawn(move || {
        stdin
            .write_all(DOC.as_bytes())
            .expect("Failed to write to stdin");
    });

    let output = child.wait_with_output().expect("Failed to read stdout");
    println!("{}", String::from_utf8(output.stdout).unwrap());
}

fn lib() {
    let source = Source::detached(DOC);
    let mut font_book = FontBook::new();
    font_book.push(FontInfo::new(FONT, 0).unwrap());
    let world = MyWorld {
        source,
        book: Prehashed::new(font_book),
        library: Prehashed::new(Library::builder().build()),
    };

    let mut tracer = Tracer::new();
    let result = typst::compile(&world, &mut tracer);
    
    match result {
        Ok(document) => {
            let buffer = typst_pdf::pdf(&document, Smart::Auto, None);
            std::fs::write("./test.pdf", buffer)
                .map_err(|err| eco_format!("failed to write PDF file ({err})")).unwrap();
        },
        Err(err) => eprintln!("{:?}", err),
    }
}

fn main() {
    //cli();
    lib();
}
