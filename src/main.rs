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

    let warnings = &tracer.warnings();
    println!("{} warnings", warnings.len());
    warnings.iter().for_each(|warning| {
        println!("Warning: {:?}", warning);
    });

    match result {
        Ok(document) => {
            println!("Generating PDF...");
            let pdf_gen_start = Instant::now();
            let buffer = typst_pdf::pdf(&document, Smart::Auto, None);
            let file_name = format!("{}.pdf", cli.model);
            std::fs::write(&file_name, buffer)
                .map_err(|err| eco_format!("failed to write PDF file ({err})"))
                .unwrap();
            println!("Wrote PDF to {file_name}");
            println!(
                "PDF generation took {} ms",
                pdf_gen_start.elapsed().as_millis()
            );
        }
        Err(err) => eprintln!("{:?}", err),
    }
    println!("Finished after {} ms", start.elapsed().as_millis());
}
