use lib_flutter_rust_bridge_codegen::{
    config_parse, frb_codegen, get_symbols_if_no_duplicates, RawOpts,
};

/// flutter_rust_bridge_codegen -r src\\lib.rs -d C:\\Users\\motalleb\\Documents\\GitHub\\rust_test\\k_means_dart\\lib\\external\\ffi_api.dart
///
/// Path of input Rust code
const RUST_INPUT: &str = "src\\lib.rs";
/// Path of output generated Dart code
const DART_OUTPUT: &str =
    "C:\\Users\\motalleb\\Documents\\GitHub\\rust_test\\k_means_dart\\lib\\external\\ffi_api.dart";

fn main() {
    // Tell Cargo that if the input Rust code changes, to rerun this build script.
    println!("cargo:rerun-if-changed={}", RUST_INPUT);
    // Options for frb_codegen
    let raw_opts = RawOpts {
        // Path of input Rust code
        rust_input: vec![RUST_INPUT.to_string()],
        // Path of output generated Dart code
        dart_output: vec![DART_OUTPUT.to_string()],
        // for other options use defaults
        ..Default::default()
    };
    // get opts from raw opts
    let configs = config_parse(raw_opts);

    // generation of rust api for ffi
    let all_symbols = get_symbols_if_no_duplicates(&configs).unwrap();
    for config in configs.iter() {
        frb_codegen(config, &all_symbols).unwrap();
    }
}
