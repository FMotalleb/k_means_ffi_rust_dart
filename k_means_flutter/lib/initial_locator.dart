import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:k_means_flutter/ffi.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeLib() async {
  final samplePoints =
      List.generate(15, (index) => PointPub(x: Random().nextDouble() * 900, y: Random().nextDouble() * 900));
  final k = 3;
  final begin = DateTime.now();

  final result = await FFI_PORTAL.kmeans(points: samplePoints, outputCount: k);
  final end = DateTime.now();
  print('kmeans took ${end.difference(begin).inMilliseconds}ms');
}

Future<String> _getLibsDir() async {
  final addr = Uri.parse("android.resource://com.example.k_means_flutter/");
  print(addr.hasAbsolutePath);
  final appDir = (await getApplicationDocumentsDirectory()).parent.path;
  final pInfo = await PackageInfo.fromPlatform();

  final libdir = join(appDir, 'lib');
  return libdir;
}
