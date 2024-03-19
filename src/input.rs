use std::path::PathBuf;

use serde::{Deserialize, Serialize};
use typst::foundations::Bytes;

/// Defines the available models and what their input parameters are.
#[derive(Serialize, Deserialize)]
#[serde(tag = "model", content = "input")]
pub enum PdfModel {
    #[serde(rename = "model-o-7")]
    ModelO7(ModelO7Input),
    #[serde(rename = "model-p-22-1")]
    ModelP22_1(ModelP22_1Input),
}

#[derive(Serialize, Deserialize)]
pub struct ModelO7Input {
    gen_datum: String,
    leden_van: String,
    datum: String,
    kiesring: String,
    stemmen: Vec<Lijst>,
}

#[derive(Serialize, Deserialize)]
pub struct Lijst {
    naam: String,
    lijstnummer: u64,
    kandidaten: Vec<Kandidaat>,
}

#[derive(Serialize, Deserialize)]
pub struct Kandidaat {
    positie: u64,
    name: String,
    votes: u64,
}

#[derive(Serialize, Deserialize)]
pub struct ModelP22_1Input {

}

impl PdfModel {
    /// Get the filename for the input and template
    pub fn as_filename(&self) -> &'static str {
        use PdfModel::*;
        match self {
            ModelO7(_) => "model-o-7",
            ModelP22_1(_) => "model-p-22-1",
        }
    }

    /// Get the path for the template of this model
    pub fn as_template_path(&self) -> PathBuf {
        let mut pb: PathBuf = ["templates", self.as_filename()].iter().collect();
        pb.set_extension("typ");

        pb
    }

    /// Get the path for the input of this model
    pub fn as_input_path(&self) -> PathBuf {
        let mut pb: PathBuf = ["templates", "inputs", self.as_filename()].iter().collect();
        pb.set_extension("json");

        pb
    }

    /// Get the input, serialized as json
    pub fn get_input(&self) -> serde_json::Result<Bytes> {
        use PdfModel::*;
        let data = match self {
            ModelO7(input) => serde_json::to_string(input),
            ModelP22_1(input) => serde_json::to_string(input),
        }?;

        Ok(Bytes::from(data.as_bytes()))
    }
}
