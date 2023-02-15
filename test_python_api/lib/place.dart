import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class IGNGeoService {
  static Future<List<Map<String, String>>> getSuggestions(String place) async {
    var client = http.Client();
    var uri = Uri.parse(
        "https://wxs.ign.fr/essentiels/geoportail/geocodage/rest/0.1/completion?text=$place");

    var response = await client.get(uri);

    List<PlaceSuggestion> suggestions = [];
    if (response.statusCode == 200) {
      var json = convert.jsonDecode(response.body);
      Iterable results = json['results'];
      suggestions = List<PlaceSuggestion>.from(
          results.map((model) => PlaceSuggestion.fromJson(model)));
    } else {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }

    return Future.value(suggestions
        .map((e) => {
              'fulltext': e.fulltext,
              'lat': e.lat,
              'lon': e.lon,
            })
        .toList());
  }
}

class PlaceSuggestion {
  final String country;
  final String zipcode;
  final String street;
  final String fulltext;
  final String lat;
  final String lon;

  PlaceSuggestion({
    required this.country,
    required this.zipcode,
    required this.street,
    required this.fulltext,
    required this.lat,
    required this.lon,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      country: json['country'],
      zipcode: json['zipcode'],
      street: json['street'],
      fulltext: json['fulltext'],
      lat: json['y'].toString(),
      lon: json['x'].toString(),
    );
  }
}
