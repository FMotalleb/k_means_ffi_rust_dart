import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'dart:ffi' as ffi;

import 'bridge_generated.dart';

typedef ClusteringResult = List<ClusteringResultStruct>;
typedef Point = PointStruct;

const String _libName = '_ffi_clustering';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final ClusteringFfiRustImpl _bindings = ClusteringFfiRustImpl(_dylib);

abstract class ClusteringFFI {
  static Future<ClusteringResult> kmeansClustering(
    List<Point> points,
    int clusterCount,
  ) {
    return _bindings.kmeans(
      points: points,
      outputCount: clusterCount,
    );
  }

  static Future<ClusteringResult> opticsClustering({
    required List<Point> points,
    required double epsilon,
    int minPts = 1,
  }) {
    return _bindings.optics(
      points: points,
      eps: epsilon,
      minPts: minPts,
    );
  }
}
