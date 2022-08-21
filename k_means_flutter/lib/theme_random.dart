import 'package:dio/dio.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

Future<Theme> getMapTheme() async {
  final jsonData = await Dio().get('https://tiles.stadiamaps.com/styles/alidade_smooth.json');
  return ThemeReader().read(jsonData.data);
  final test = ProvidedThemes.lightTheme();

  return ProvidedThemes.lightTheme();
}
