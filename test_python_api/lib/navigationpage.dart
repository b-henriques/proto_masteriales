import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:test_python_api/position.dart';
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
        futurePath = fetchPath(LatLng(posvalue!.latitude!, posvalue.longitude!),
            widget.destination, value.range);
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
              child: FutureBuilder(
                future: position,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FlutterMap(
                      options: MapOptions(
                        center: LatLng(snapshot.data!.latitude!,
                            snapshot.data!.longitude!),
                        zoom: 15,
                        maxZoom: 18,
                      ),
                      nonRotatedChildren: [
                        AttributionWidget.defaultWidget(
                          source: 'OpenStreetMap contributors',
                          onSourceTapped: null,
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                width: 2.0,
                                color: Colors.black,
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<BatteryStatus>(
                              future: batteryStatus,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                              Icons.battery_4_bar_outlined),
                                          Text(
                                              "${snapshot.data?.charge.toStringAsFixed(2)} %"),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.time_to_leave),
                                          Text(
                                              "${snapshot.data?.range.toStringAsFixed(2)} Kms"),
                                        ],
                                      ),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const Text("Fetching Battery Status");
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                width: 2.0,
                                color: Colors.black,
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            //TODO: display intructions
                            child: Column(children: const [
                              Icon(Icons.u_turn_left),
                              Text("Uturn"),
                            ]),
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
                            return Text("");
                          },
                        ),
                        RechargeStationsMarkerLayer(),
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
            )
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
