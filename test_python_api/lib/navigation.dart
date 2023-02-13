import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
//import 'package:geolocator/geolocator.dart';

class PathPolylineLayer extends StatefulWidget {
  const PathPolylineLayer({super.key});

  @override
  State<PathPolylineLayer> createState() => _PathPolylineLayerState();
}

class _PathPolylineLayerState extends State<PathPolylineLayer> {
  late Future<List<Polyline>> futurePath;
  late LatLng position;

  @override
  void initState() {
    super.initState();
    position = LatLng(48.6158982, 2.42770525);
    futurePath =
        fetchPath(LatLng(48.626067, 2.424743), LatLng(48.709696, 2.167326), 10);
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    final zoom = map.zoom;
    final bounds = map.bounds;

    return FutureBuilder<List<Polyline>>(
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
        return const Text("Fetching Path Data");
      },
    );
  }
}

Future<List<Polyline>> fetchPath(
    LatLng sposition, LatLng eposition, double rangeInKms) async {
  var client = http.Client();

  var uri = Uri.parse(
      "http://10.0.2.2:5000/itineraire/position=${sposition.latitude},${sposition.longitude}&destination=${eposition.latitude},${eposition.longitude}&range=$rangeInKms");

  print("SEND");
  var response = await client.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Polyline> pathPolylines = List.empty(growable: true);
    var path = jsonDecode(response.body);
    print(path);
    //create a polyline for path
    pathJsonToPolyline(path!["geometry"]["coordinates"], pathPolylines);

    return pathPolylines;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed To Load Path');
  }
}

void pathJsonToPolyline(
  element,
  pathPolylines,
) {
  List<LatLng> points = List.empty(growable: true);
  element.forEach((p) {
    points.add(LatLng(p[1].toDouble(), p[0].toDouble()));
  });
  pathPolylines.add(
    Polyline(
      points: points,
      color: Colors.deepOrange.shade400,
      strokeWidth: 5.0,
    ),
  );
}
