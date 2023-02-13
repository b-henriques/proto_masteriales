import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:test_python_api/stations.dart';

import 'navigation.dart';
import 'package:http/http.dart' as http;

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // timer for update
  late Timer timer;
  // battery status
  late Future<BatteryStatus> batteryStatus;
  // path
  late Future<List<Polyline>> futurePath;
  // position
  late LatLng position;

  late DateTime lastUploadDate;

  @override
  void initState() {
    super.initState();

    //TODO:
    // set initial position
    position = LatLng(48.6158982, 2.42770525);
    // fetch battery status
    batteryStatus = fetchBatteryStatus();
    // fetch path
    futurePath = fetchPath(position, LatLng(48.709696, 2.167326), 10);
    // set last upload date
    lastUploadDate = DateTime.now();
    //
    double lastBatteryCharge = 0;
    batteryStatus.then((value) => lastBatteryCharge = value.charge);

    //update every x seconds
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) async {
      // update battery status
      batteryStatus = fetchBatteryStatus();

      //update position
      //TODO:
      // if Y seconds passed force fetch path
      if (DateTime.now().difference(lastUploadDate).inSeconds >= 60) {
        //TODO:
      }
      //TODO:
      // else {
      //   // if battery variation is big fetch path
      //   if (false) {
      //   } else {
      //     if (false) {
      //       // if detour fetch path
      //     }
      //   }
      // }

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
        title: const Text("Navigation"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(48.626067, 2.424743),
                  zoom: 15,
                  maxZoom: 18,
                ),
                nonRotatedChildren: [
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.0,
                        color: Colors.black,
                      ),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.battery_4_bar_outlined),
                            FutureBuilder<BatteryStatus>(
                              future: batteryStatus,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                      "${snapshot.data?.charge.toStringAsFixed(2)} %");
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                // By default, show a loading spinner.
                                return const Text("Fetching Battery Status");
                              },
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_auto_rounded),
                            FutureBuilder<BatteryStatus>(
                              future: batteryStatus,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                      "${snapshot.data?.range.toStringAsFixed(2)} Kms");
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                // By default, show a loading spinner.
                                return const Text("Fetching Battery Status");
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  FutureBuilder<List<Polyline>>(
                    future: futurePath,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PolylineLayer(
                          polylines: snapshot.data!,
                          polylineCulling: true,
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      // By default, show a loading spinner.
                      return Text("");
                    },
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

class BatteryStatus {
  double charge = 0;
  double range = 0;

  BatteryStatus(double vcharge, double vrange) {
    charge = vcharge;
    range = vrange;
  }
}

Future<BatteryStatus> fetchBatteryStatus() async {
  var client = http.Client();

  var uri = Uri.parse("http://10.0.2.2:5000/battery/status");

  var response = await client.get(uri);

  var status = jsonDecode(response.body);

  BatteryStatus res =
      BatteryStatus(status['charge'].toDouble(), status['range'].toDouble());
  return res;
}
