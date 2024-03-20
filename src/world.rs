use std::collections::HashMap;

use comemo::Prehashed;
use typst::{
    diag::{FileError, FileResult},
    foundations::{Bytes, Datetime},
    syntax::{FileId, Source, VirtualPath},
    text::{Font, FontBook},
    Library, World,
};

use crate::input::PdfModel;

/// Contains the context for rendering PDFs.
pub struct PdfWorld {
    sources: Vec<Source>,
    library: Prehashed<Library>,
    fontbook: Prehashed<FontBook>,
    assets: HashMap<FileId, Bytes>,
    fonts: Vec<Font>,
    main_source: Source,
    input_data: (FileId, Bytes),
}

impl PdfWorld {
    /// Create a new context for rendering PDFs.
    ///
    /// This preloads all files configured in the load_sources, load_fonts and
    /// load_assets functions. Make sure to update their contents if the files
    /// for the templates have changed (this step is manual to ensure that all
    /// template files are actually available).
    pub fn new() -> PdfWorld {
        let sources = load_sources();
        let (fonts, fontbook) = load_fonts();
        let assets = load_assets();
        PdfWorld {
            sources,
            fontbook: Prehashed::new(fontbook),
            fonts,
            assets,
            library: Prehashed::new(Library::builder().build()),
            main_source: Source::new(FileId::new(None, VirtualPath::new("empty.typ")), "".into()),
            input_data: (
                FileId::new(None, VirtualPath::new("input.json")),
                Bytes::from_static(&[]),
            ),
        }
    }

    /// Set the input model for this instance.
    ///
    /// The input model defines which template is being used and what the input
    /// for that template is.
    pub fn set_input_model(&mut self, input: PdfModel) {
        let main_source_path = input.as_template_path();
        let main_source = self
            .sources
            .iter()
            .find(|s| s.id().vpath().as_rootless_path() == main_source_path)
            .cloned()
            .unwrap();
        let input_path = input.as_input_path();
        let input_data = input.get_input().unwrap();
        self.main_source = main_source;
        self.input_data = (FileId::new(None, VirtualPath::new(input_path)), input_data);
    }
}

impl World for PdfWorld {
    fn library(&self) -> &Prehashed<Library> {
        &self.library
    }

    fn book(&self) -> &Prehashed<FontBook> {
        &self.fontbook
    }

    fn main(&self) -> Source {
        self.main_source.clone()
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        for source in &self.sources {
            if source.id() == id {
                return Ok(source.clone());
            }
        }

        Err(FileError::NotFound(id.vpath().as_rootless_path().into()))
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        // if the file we need is the input file, pass that
        if self.input_data.0 == id {
            return Ok(self.input_data.1.clone());
        }

        // otherwise it must be one of the other files
        self.assets
            .get(&id)
            .cloned()
            .ok_or(FileError::NotFound(id.vpath().as_rootless_path().into()))
    }

    fn font(&self, index: usize) -> Option<Font> {
        self.fonts.get(index).cloned()
    }

    fn today(&self, offset: Option<i64>) -> Option<Datetime> {
        use chrono::Datelike;

        // get the current time using chrono
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

/// Macro that loads data from a file
/// In a debug build, this is done at runtime, for a release build this is
/// done at compile time.
macro_rules! include_filedata {
    ($path:literal) => {
        if cfg!(debug) {
            // we are leaking the data into a static slice
            Box::leak(std::fs::read($path).unwrap().into_boxed_slice())
        } else {
            include_bytes!(concat!("../", $path)) as &'static [u8]
        }
    };
}

/// Macro that loads data as a string from a file
/// In a debug build, this is done at runtime, for a release build this is
/// done at compile time.
macro_rules! include_strdata {
    ($path:literal) => {
        if cfg!(debug) {
            // we are leaking the data into a static string slice
            Box::leak(std::fs::read_to_string($path).unwrap().into_boxed_str())
        } else {
            include_str!(concat!("../", $path)) as &'static str
        }
    };
}

/// Load all sources available from the `templates/` directory (i.e. all typst
/// files).
fn load_sources() -> Vec<Source> {
    macro_rules! include_source {
        ($path:literal) => {
            Source::new(
                FileId::new(None, VirtualPath::new($path)),
                include_strdata!($path).to_string(),
            )
        };
    }

    vec![include_source!("templates/model-o-7.typ")]
}

/// Load all fonts available from the `fonts/` directory
fn load_fonts() -> (Vec<Font>, FontBook) {
    let mut fonts = vec![];
    let mut fontbook = FontBook::new();

    macro_rules! include_font {
        ($path:literal) => {
            let fontdata = include_filedata!($path);
            let font = Font::new(Bytes::from_static(fontdata), 0).expect("Error reading font file");
            fontbook.push(font.info().clone());
            fonts.push(font);
        };
    }

    include_font!("fonts/bitstream-vera/Vera.ttf");
    include_font!("fonts/bitstream-vera/VeraBd.ttf");
    include_font!("fonts/bitstream-vera/VeraBI.ttf");
    include_font!("fonts/bitstream-vera/VeraIt.ttf");

    (fonts, fontbook)
}

/// Load all assets from the assets directory at `templates/assets`
fn load_assets() -> HashMap<FileId, Bytes> {
    HashMap::new()
}
