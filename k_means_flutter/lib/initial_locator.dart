import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:k_means_flutter/ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeLib() async {
  const libName = 'lib_kmeans.so';
  final libDir = await _getLibsDir();
  final libPath = join(libDir, libName);

  K_MEANS_API = KMeansRustImpl(
    DynamicLibrary.open(libPath),
  );
}

Future<String> _getLibsDir() async {
  final appDir = (await getApplicationSupportDirectory()).parent.path;
  final libdir = join(appDir, 'lib');
  return libdir;
}
