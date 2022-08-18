import 'dart:ffi';
import 'dart:math';

import 'package:k_means_dart/external/ffi_api.dart';
import 'package:k_means_dart/k_means_dart.dart';

const dllPath = r'C:\Users\motalleb\Documents\GitHub\rust_test\k_means_dart\example\k_means_rust.dll';
void main() async {
  final testLists = [15, 50, 150, 600];
  final library = DynamicLibrary.open(dllPath);
  final km = KMeansRustImpl(library);
  for (final i in testLists) {
    final begin = DateTime.now();
    List<Point> points =
        List.generate(50, (index) => Point(x: Random().nextDouble() * 1500, y: Random().nextDouble() * 1500));

    final result = await km.kmeans(points: points, outputCount: 15);
    final end = DateTime.now();
    print('$i points: ${end.difference(begin).inMilliseconds}ms');
    print('output : ${result.length}');
  }
}
