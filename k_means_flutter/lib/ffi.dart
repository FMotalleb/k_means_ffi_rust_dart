// This file initializes the dynamic library and connects it with the stub
// generated by flutter_rust_bridge_codegen.

// ignore_for_file: non_constant_identifier_names

import 'bridge_generated.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'bridge_generated.dart';

late final KMeansRustImpl K_MEANS_API;
