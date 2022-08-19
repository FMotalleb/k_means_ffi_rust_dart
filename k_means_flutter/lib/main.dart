import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_toolkit/flutter_map_toolkit.dart';
import 'package:k_means_flutter/ffi.dart';
import 'package:k_means_flutter/initial_locator.dart';
import 'package:latlong2/latlong.dart';

String excva = 'not initialized';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeLib();
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
  final _markers = [
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(53.3498, -6.2603),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(53.3488, -6.2613),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(53.3488, -6.2613),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(48.8566, 2.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
    Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 30,
      width: 30,
      point: LatLng(49.8566, 3.3522),
      builder: (ctx) => const Icon(Icons.pin_drop),
    ),
  ];
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
    LiveMarkerPlugin(),
    MarkerClusterPlugin(),
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

  @override
  Widget build(BuildContext context) {
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
                  adaptiveBoundaries: false,
                  onTap: (tapPosition, point) {
                    _mapEventTap.update(point);
                  },
                  center: LatLng(53.3488, -6.2613),
                  zoom: 5,
                ),
                layers: [
                  /// base map tile backed by mapbox
                  TileLayerOptions(
                    maxNativeZoom: 15,
                    urlTemplate: _mapBoxAddress,
                  ),

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
                      view: (context) => SizedBox(),
                    ),
                    removeOnTap: true,
                    mapEventLink: _mapEventTap,
                  ),

                  /// draw selected points on map
                  LiveMarkerOptionsWithStream(
                    pointsInfoProvider: pointProvider,
                    markers: {
                      'm0': MarkerInfo(
                          view: (_) => Icon(
                                Icons.gpp_good_sharp,
                                color: Colors.black.withOpacity(0.2),
                              )),
                      'm1': MarkerInfo(
                          view: (_) => Icon(
                                Icons.gps_fixed,
                                color: Colors.black.withOpacity(0.2),
                              )),
                    },
                  ),
                  MarkerClusterLayerOptions(
                    spiderfyCircleRadius: 80,
                    spiderfySpiralDistanceMultiplier: 2,
                    circleSpiralSwitchover: 12,
                    maxClusterRadius: 120,
                    rotate: true,
                    size: const Size(40, 40),
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: const FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                      maxZoom: 15,
                    ),
                    markers: _markers,
                    polygonOptions: const PolygonOptions(
                        borderColor: Colors.blueAccent, color: Colors.black12, borderStrokeWidth: 3),
                    popupOptions: PopupOptions(
                        popupSnap: PopupSnap.markerTop,
                        popupBuilder: (_, marker) => Container(
                              width: 200,
                              height: 100,
                              color: Colors.white,
                              child: GestureDetector(
                                onTap: () => debugPrint('Popup tap!'),
                                child: Text(
                                  'Container popup for marker at ${marker.point}',
                                ),
                              ),
                            )),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.blue),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
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
      (e) => PointInfo(
        rotation: 0,
        position: e,
        iconId: iconIds.random,
      ),
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
        // if (lastAccessiblePoint != null) {
        //   return lastAccessiblePoint!.contains(element.position);
        // }
        return true;
      },
    ).toList();

    if (output.length > 4) {
      final beg = DateTime.now();
      final result = await K_MEANS_API.kmeans(
          points: output.map((e) => Point(x: e.position.longitude, y: e.position.latitude)).toList(), outputCount: 4);
      final end = DateTime.now();
      print('took: ${end.difference(beg)}');
      emit(result.map((e) => PointInfo(iconId: 'm1', rotation: 0, position: LatLng(e.points.y, e.points.x))).toList());
    } else {
      emit(output);
    }
  }

  LatLngBounds? lastAccessiblePoint;
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
