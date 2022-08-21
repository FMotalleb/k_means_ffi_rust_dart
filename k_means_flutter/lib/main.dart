import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_toolkit/flutter_map_toolkit.dart';
import 'package:k_means_flutter/ffi.dart';
import 'package:k_means_flutter/initial_locator.dart';
import 'package:k_means_flutter/theme_random.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as tt;

String excva = 'not initialized';
late tt.Theme mapTheme;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeLib();
  mapTheme = await getMapTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter_Map_Toolkit Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DistanceInfo? distanceInfo;

  static const _mapboxPublicToken =
      'pk.eyJ1IjoiZm1vdGFsbGViIiwiYSI6ImNsNWppYXJiZjAwZGwzbG5uN2NqcHc2a3EifQ.sDOg7Y2k9Nxat1MlkPj2lg';
  final httpClient = Dio();
  final _mapEventTap = MapTapEventHandler();
  late final directionProvider = MapboxDirectionProvider(
    mapboxToken: _mapboxPublicToken,
    getRequestHandler: (String url) async {
      final response = await httpClient.get<Map<String, dynamic>>(
        url,
      );
      return response.data!;
    },
  );
  final directionController = DirectionsLayerController();
  final _points = <LatLng>[];
  final plugins = [
    PointSelectorPlugin(),
    DirectionsPlugin(),
    LiveMarkerPlugin(), VectorMapTilesPlugin(),
    // MarkerClusterPlugin(),
  ];
  final _mapBoxAddress = mapBoxUrlBuilder(
    style: 'fmotalleb/cl6m8kuee009v16pkv7m6mxgs',
    is2x: true,
    accessToken: _mapboxPublicToken,
  );

  final pointProvider = SampleStreamedPointProvider();
  void onPointSelect(PointSelectionEvent event) {
    if (event.state == PointSelectionState.select) {
      if (event.point != null) {
        _points.add(event.point!);
        setState(() {
          distanceInfo = directionController.lastPath?.distanceToPoint(
            event.point!,
          );
        });
        pointProvider.controller.insert(event.point!);
      }
    } else if (event.point != null) {
      _points.remove(event.point);
      pointProvider.controller.remove(event.point!);
    }
    if (_points.length > 1) {
      directionController.requestDirections(_points);
    }
  }

  VectorTileProvider _cachingTileProvider(String urlTemplate) {
    return NetworkVectorTileProvider(
        urlTemplate: urlTemplate,
        // this is the maximum zoom of the provider, not the
        // maximum of the map. vector tiles are rendered
        // to larger sizes to support higher zoom levels

        maximumZoom: 14);
  }

  _mapTheme(BuildContext context) {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    // return Provided.lightTheme();
  }

  String _urlTemplate() {
    // Stadia Maps source https://docs.stadiamaps.com/vector/
    // return 'http://a.tiles.mapbox.com/v4/mapbox.mapbox-streets-v8/{z}/{x}/{y}.mvt?access_token=pk.eyJ1IjoiZm1vdGFsbGViIiwiYSI6ImNsNWppYXJiZjAwZGwzbG5uN2NqcHc2a3EifQ.sDOg7Y2k9Nxat1MlkPj2lg';
    return 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=efad6a1b-4197-4cfc-993e-9d8582a6fc2e';
    return 'https://map.ir/vector/tms/1.0.0/Shiveh:Vector@EPSG:3857@pbf/5/16/9.pbf?x-api-key=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImI2MjFjY2M4NTE5YzcwMzc3M2FhNWFiODhlMWFjNDExYjU0YTcxM2Q3OTAxNDZmNTdjNjBhZWQ1MmE0YmMyYzBjYWIyY2RhNTM0ZWNkMTk0In0.eyJhdWQiOiIxOTA4MSIsImp0aSI6ImI2MjFjY2M4NTE5YzcwMzc3M2FhNWFiODhlMWFjNDExYjU0YTcxM2Q3OTAxNDZmNTdjNjBhZWQ1MmE0YmMyYzBjYWIyY2RhNTM0ZWNkMTk0IiwiaWF0IjoxNjYwMzkwMDI5LCJuYmYiOjE2NjAzOTAwMjksImV4cCI6MTY2Mjk4MjAyOSwic3ViIjoiIiwic2NvcGVzIjpbImJhc2ljIl19.XA_vy45x9PuitO30pt8iWPSVrl-eb_-7h4_RZWbXpeBXliB6UoH0JlbOHLVkjTurCK9rW_Y8Avtb3uCPvk7xbs81XTebuDDYpKl87IIR6llAxVrFVXdWodY_ytce0iw-AHIAPu_vH_fDyE1cnH_BofYHoIvVGN62kHbH-d2EBgW_h-t4sXJsOAMQj22_nMCuftm4vRFdpIM6Hh8Mz4hKdEkFquSLudjx5dM1-O7i6-NMhCm_5bBzjpX1NvEPIXv-zIbPwFMLJ4ji2XVSRWIYkl71C5qse20lmezApTvNz-Ky9ej5aSk1WNR22DtXdijCkcdzcvX1rjGvSgLagUvyBg';

    // Mapbox source https://docs.mapbox.com/api/maps/vector-tiles/#example-request-retrieve-vector-tiles
    // return 'https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/{z}/{x}/{y}.mvt?access_token=$apiKey',
  }

  @override
  Widget build(BuildContext context) {
    var tileLayerOptions = VectorTileLayerOptions(
      theme: mapTheme,

      // showTileDebugInfo: true,
      tileProviders: TileProviders({
        'openmaptiles': _cachingTileProvider(_urlTemplate()),
      }),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  plugins: plugins,
                  minZoom: 5,
                  maxZoom: 18,
                  rotation: 0,
                  adaptiveBoundaries: false,
                  onTap: (tapPosition, point) {
                    _mapEventTap.update(point);
                  },
                  center: LatLng(36, 53.3488),
                  zoom: 5,
                ),
                layers: [
                  /// base map tile backed by mapbox
                  tileLayerOptions,

                  if (distanceInfo != null) ...[
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: distanceInfo!.source,
                          builder: (ctx) => const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),
                        Marker(
                          width: 80,
                          height: 80,
                          point: distanceInfo!.destination,
                          builder: (ctx) => const Icon(
                            Icons.location_off,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                          points: [
                            distanceInfo!.source,
                            distanceInfo!.destination,
                          ],
                          strokeWidth: 3,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],

                  /// direction layer for showing the route between selected points
                  // DirectionsLayerOptions(
                  //   provider: directionProvider,
                  //   useCachedRoute: true,
                  //   controller: directionController,
                  //   loadingBuilder: (context) {
                  //     return const Center(
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  // ),

                  PointSelectorOptions(
                    onPointSelected: onPointSelect,
                    marker: MarkerInfo(
                      view: (context, _) => SizedBox(),
                    ),
                    removeOnTap: true,
                    mapEventLink: _mapEventTap,
                  ),

                  /// draw selected points on map
                  LiveMarkerOptionsWithStream(
                    pointsInfoProvider: pointProvider,
                    markers: {
                      'm0': MarkerInfo(
                          view: (_, info) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Text((info.metaData['count'] ?? 1).toString()),
                              )),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension Randomize<T> on List<T> {
  T get random => this[Random().nextInt(length)];
  List<T> randomize() {
    final result = toList();
    result.shuffle();
    return result;
  }
}

class SamplePointsEventCubit extends Cubit<List<PointInfo>> {
  SamplePointsEventCubit(this.iconIds, [super.initialState = const []]);
  final List<String> iconIds;
  final _points = <LatLng>[];
  int get pointsCount => _points.length;
  Iterable<PointInfo> get _information {
    return _points.map(
      (e) => PointInfo(rotation: 0, position: e, iconId: iconIds.random, metaData: {}),
    );
  }

  void refresh() {
    emitInformation();
  }

  void removeAll() {
    _points.clear();
    emit([]);
  }

  void insert(LatLng point) {
    _points.add(point);
    emitInformation();
  }

  void remove(LatLng point) {
    _points.remove(point);
    emitInformation();
  }

  Future<void> emitInformation() async {
    final output = _information.where(
      (element) {
        if (lastAccessiblePoint != null) {
          return lastAccessiblePoint.contains(element.position);
        }
        return true;
      },
    ).toList();

    if (output.length > 4) {
      final epsilon = (lastAccessiblePoint.east - lastAccessiblePoint.west).abs();
      final beg = DateTime.now();
      final points = output.map((e) => PointPub(x: e.position.longitude, y: e.position.latitude)).toList();
      // final result = await K_MEANS_API.kmeans(points: points, outputCount: 4);
      final result = await dbscan(points, epsilon / 5, 1);
      print(epsilon);
      final end = DateTime.now();
      print('took: ${end.difference(beg)}');
      emit(result
          .map(
            (e) => PointInfo(
              iconId: 'm0',
              rotation: 0,
              position: LatLng(e.point.y, e.point.x),
              metaData: {
                'count': e.sourceIndexes.length,
              },
            ),
          )
          .toList());
    } else {
      emit(output);
    }
  }

  LatLngBounds lastAccessiblePoint = LatLngBounds(LatLng(53.3488, -6.2613), LatLng(55.3488, -4.2613));
  Stream<List<PointInfo>> generatePoints(Stream<MapInformationRequestParams?> input) {
    input.listen((event) {
      if (event != null) {
        lastAccessiblePoint = event.viewPort;
      }
      refresh();
    });
    return stream;
  }
}

class SampleStreamedPointProvider extends PointInfoStreamedProvider {
  final controller = SamplePointsEventCubit([
    'm0',
  ]);
  @override
  Stream<List<PointInfo>> getPointStream(
    Stream<MapInformationRequestParams?> params,
  ) =>
      controller.generatePoints(params);

  @override
  void invoke() {
    controller.refresh();
  }
}

Future<List<KMeansResultRow>> dbscan(List<PointPub> points, double epsilon, int minPoints) async {
  // final scanner = DBSCAN(epsilon: epsilon, minPoints: minPoints);
  // final dataset = points
  //     .map((e) => [
  //           e.y,
  //           e.x,
  //         ])
  //     .toList();

  // final outputRaw = scanner.run(dataset);
  final outputRaw = await FFI_PORTAL.optics(points: points, eps: epsilon, minPts: minPoints);
  final output = outputRaw.toList(growable: true);
  List<PointPub> selectedPoints = [];

  for (final cluster in outputRaw) {
    final pts = points.selectThese(cluster.sourceIndexes);
    selectedPoints.addAll(pts);
  }
  final soloPoints = points.where((e) => !selectedPoints.contains(e)).toList();
  for (final p in soloPoints) {
    output.add(KMeansResultRow(point: p, sourceIndexes: Int32List.fromList([0])));
  }
  return output;
}

extension PointsTools on List<PointPub> {
  PointPub centerOf(List<int> indexes) {
    final x = indexes.map((e) => this[e].x).reduce((a, b) => a + b);
    final y = indexes.map((e) => this[e].y).reduce((a, b) => a + b);
    return PointPub(x: x / indexes.length, y: y / indexes.length);
  }

  List<PointPub> selectThese(List<int> indexes) {
    final output = <PointPub>[];
    for (int i = 0; i < length; i++) {
      if (indexes.contains(i)) {
        output.add(this[i]);
      }
    }
    return output;
  }
}
