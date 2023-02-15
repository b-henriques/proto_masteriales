import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:test_python_api/pickdestinationpage.dart';
import 'package:test_python_api/position.dart';
import 'package:test_python_api/stations.dart';

/*
https://docs.fleaflet.dev/
*/

void main() => runApp(
      MaterialApp(
        home: MyApp(),
        title: 'ProofOfConceptApp',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
      ),
    );

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    position = getPosition();
  }

  // position
  Future<LocationData?>? position;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProofOfConceptApp'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FutureBuilder(
                future: position,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FlutterMap(
                      options: MapOptions(
                          center: LatLng(snapshot.data!.latitude!,
                              snapshot.data!.longitude!),
                          zoom: 15,
                          maxZoom: 18),
                      nonRotatedChildren: [
                        AttributionWidget.defaultWidget(
                          source: 'OpenStreetMap contributors',
                          onSourceTapped: null,
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width - 80,
                          top: MediaQuery.of(context).size.height - 200,
                          child: RawMaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PickDestinationPage()),
                              );
                            },
                            elevation: 2.0,
                            fillColor: Colors.white,
                            padding: EdgeInsets.all(15.0),
                            shape: CircleBorder(),
                            child: const Icon(
                              Icons.navigation_rounded,
                              size: 35.0,
                            ),
                          ),
                        ),
                      ],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.protoMasteriales.app',
                        ),
                        const RechargeStationsMarkerLayer(),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(snapshot.data!.latitude!,
                                  snapshot.data!.longitude!),
                              builder: (context) {
                                return Transform.rotate(
                                  angle: snapshot.data!.heading!,
                                  child: Icon(
                                    Icons.adjust,
                                    size: 500 /
                                        (FlutterMapState.maybeOf(context)!
                                            .zoom),
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
