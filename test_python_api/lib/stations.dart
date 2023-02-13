import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
//import 'package:geolocator/geolocator.dart';

Future<List<Marker>> fetchStations(
    LatLng position, double distanceInKms) async {
  var client = http.Client();

  var uri = Uri.parse(
      "http://10.0.2.2:5000/stationsInRange/position=${position.latitude},${position.longitude}&range=$distanceInKms");

  var response = await client.get(uri);
  /*final response =
      await http.get(Uri.http("http://10.0.2.2:5000/", '/'));*/

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Marker> stationsMarkers = List.empty(growable: true);
    var stations = jsonDecode(response.body);

    //create a marker for each station
    stations!.forEach((element) {
      stationJsonToMarker(element, stationsMarkers);
    });

    return stationsMarkers;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed To Load Recharge Stations');
  }
}

class RechargeStationsMarkerLayer extends StatefulWidget {
  const RechargeStationsMarkerLayer({super.key});

  @override
  State<RechargeStationsMarkerLayer> createState() =>
      _RechargeStationsMarkerLayerState();
}

//TODO: create buffer, fetch new data only when moved a certain distance within buffer
//TODO: cluster markers when zoom is low, show number of stations by loaction(departement code?)
class _RechargeStationsMarkerLayerState
    extends State<RechargeStationsMarkerLayer> {
  late Future<List<Marker>> futureStations;
  late LatLng position;

  @override
  void initState() {
    super.initState();
    position = LatLng(48.6158982, 2.42770525);
    futureStations = fetchStations(position, 10);
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    final zoom = map.zoom;
    final bounds = map.bounds;

    //futureStations = fetchStations(position, 20);

    return FutureBuilder<List<Marker>>(
      future: futureStations,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MarkerLayer(markers: snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const Text("Fetching Recharge Stations Data");
      },
    );
  }
}

void stationJsonToMarker(
  element,
  stationsMarkers,
) {
  stationsMarkers.add(
    Marker(
      width: 80,
      height: 80,
      point: LatLng((element['consolidated_latitude']).toDouble(),
          (element['consolidated_longitude']).toDouble()),
      builder: (contex) => GestureDetector(
        onTap: () {
          String nomStation = element['nom_station'] as String;
          ScaffoldMessenger.of(contex).showSnackBar(
            SnackBar(
              content: Text(nomStation),
            ),
          );
        },
        child: const Icon(
          Icons.electric_meter_rounded,
          size: 30,
          color: Colors.red,
        ),
      ),
    ),
  );
}
