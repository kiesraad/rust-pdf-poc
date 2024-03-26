use std::{fs::read_to_string, path::PathBuf, time::Instant};

use clap::Parser;
use typst::{diag::eco_format, eval::Tracer, foundations::Smart};

use crate::world::PdfWorld;

mod input;
mod world;

#[derive(Parser)]
struct Cli {
    model: String,
    input: PathBuf,
}

fn main() {
    let cli = Cli::parse();
    let data = read_to_string(cli.input).unwrap();
    let model = input::PdfModel::from_name_with_input(&cli.model, &data).unwrap();

    println!("Initializing...");
    let start = Instant::now();
    let mut world = PdfWorld::new();

    world.set_input_model(model);
    println!("Initialization took {} ms", start.elapsed().as_millis());

    println!("Starting compilation...");
    let mut tracer = Tracer::new();
    let compile_start = Instant::now();
    let result = typst::compile(&world, &mut tracer);
    println!("Compile took {} ms", compile_start.elapsed().as_millis());

    match result {
        Ok(document) => {
            println!("Generating pdf...");
            let pdf_gen_start = Instant::now();
            let buffer = typst_pdf::pdf(&document, Smart::Auto, None);
            std::fs::write("./test.pdf", buffer)
                .map_err(|err| eco_format!("failed to write PDF file ({err})"))
                .unwrap();
            println!(
                "Pdf generation took {} ms",
                pdf_gen_start.elapsed().as_millis()
            );
        }
        Err(err) => eprintln!("{:?}", err),
    }
    println!("Finished after {} ms", start.elapsed().as_millis());
}
