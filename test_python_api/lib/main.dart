import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:test_python_api/navigationpage.dart';
import 'package:test_python_api/stations.dart';

/*
https://docs.fleaflet.dev/
*/

//
// Battery simulation
// Refresh path every x tick
// Choose destination
// Recharge Station Buffer
//

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
  }

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
              child: FlutterMap(
                options: MapOptions(
                    center: LatLng(48.6158982, 2.42770525),
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
                              builder: (context) => const NavigationPage()),
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
                    userAgentPackageName: 'com.example.app',
                  ),
                  RechargeStationsMarkerLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
