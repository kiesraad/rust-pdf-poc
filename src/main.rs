use std::{
    io::Write,
    process::{Command, Stdio},
};

const DOC: &str = include_str!("../doc.typ");

fn main() {
    let mut child = Command::new("/home/marlonp/.cargo/bin/typst")
        .stdin(Stdio::piped())
        .arg("compile")
        .arg("-")
        .arg("doc.pdf")
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
