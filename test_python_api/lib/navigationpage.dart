import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:test_python_api/stations.dart';

import 'navigation.dart';

//
// Page de navigation affichant la carte, le trajet, la position actuelle
// tous les X secondes? min? le trajet est mis a jour
// TODO:

/*

Maybe use for performance improvement?
https://github.com/bjartebore/simplify/blob/main/lib/simplify.dart
*/

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int count = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    //TODO: fonction d'actualisation+simulation de batterie
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      count++;
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigation"),
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
                  Text("$count"),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  PathPolylineLayer(),
                  //RechargeStationsMarkerLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
