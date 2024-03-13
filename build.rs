use std::path::Path;

// All font files that 
const FONT_DIR: &str = "vendor/fonts";
const FONT_FILES: &[&str] = &[
    "Vera.ttf",
    "VeraBd.ttf",
    "VeraBI.ttf",
    "VeraIt.ttf",
];

macro_rules! warn {
    ($($tokens: tt)*) => {
        println!("cargo:warning={}", format!($($tokens)*))
    }
}

fn font_files_exist() {
    FONT_FILES.iter().for_each(|file_name| {
        if !Path::new(FONT_DIR).join(file_name).exists() {
            warn!("`{}` not found, will use fallback", file_name);
        }
    })
}

fn main() {
    // Simple example for compile time validation
    font_files_exist();
    let error = if !Path::new("./input.json").exists() {
        println!("input file not found!");
        true
    } else {
        false
    };

    if error {
        panic!();
    }
}
