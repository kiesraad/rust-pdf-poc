use std::{fs::read_to_string, time::Instant};

use typst::{diag::eco_format, eval::Tracer, foundations::Smart};
use typst_pdf;

use crate::world::PdfWorld;

mod input;
mod world;

fn main() {
    println!("Initializing...");
    let start = Instant::now();
    let mut world = PdfWorld::new();
    world.set_input_model(input::PdfModel::ModelO7(serde_json::from_str(&read_to_string("templates/inputs/model-o-7.json").unwrap()).unwrap()));
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
            println!("Pdf generation took {} ms", pdf_gen_start.elapsed().as_millis());
        }
        Err(err) => eprintln!("{:?}", err),
    }
    println!("Finished after {} ms", start.elapsed().as_millis());
}
