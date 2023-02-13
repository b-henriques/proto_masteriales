import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:test_python_api/stations.dart';

import 'navigation.dart';
import 'package:http/http.dart' as http;

import 'package:location/location.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, required this.destination});

  final LatLng destination;
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // timer for update
  late Timer timer;
  // battery status
  Future<BatteryStatus>? batteryStatus;
  // path
  Future<List<Polyline>>? futurePath;
  // position
  Future<LocationData?>? position;

  DateTime lastUploadDate = DateTime.now();

  double lastBatteryCharge = 0;

  Location location = Location();

  @override
  void initState() {
    super.initState();

    // fetch battery status
    batteryStatus = fetchBatteryStatus();
    batteryStatus?.then((value) {
      position = getPosition();
      // set initial position
      position!.then((posvalue) {
        // fetch path
        futurePath = fetchPath(
            LatLng(posvalue!.latitude!, posvalue!.longitude!),
            widget.destination,
            value.range);
        // set lastbatterycharge
        lastBatteryCharge = value.charge;
        // set last upload date
        lastUploadDate = DateTime.now();
      });
    });

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

  Future<LocationData?> getPosition() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return locationData;
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
                  FutureBuilder<LocationData?>(
                    future: position,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(snapshot.data!.latitude!,
                                  snapshot.data!.longitude!),
                              builder: (context) {
                                return const Icon(Icons.circle);
                              },
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return Text("");
                    },
                  )
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
