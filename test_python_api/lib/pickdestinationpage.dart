import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_python_api/navigationpage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:test_python_api/place.dart';

class PickDestinationPage extends StatelessWidget {
  const PickDestinationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Destination"),
      ),
      body: const PickDestinationForm(),
    );
  }
}

class PickDestinationForm extends StatefulWidget {
  const PickDestinationForm({Key? key}) : super(key: key);

  @override
  PickDestinationFormState createState() => PickDestinationFormState();
}

class RouteData {
  String? destination = '';
}

class PickDestinationFormState extends State<PickDestinationForm> {
  // classe representant le chemin a donner dans le cas de navigation
  RouteData routeData = RouteData();

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Scrollbar(
      child: SingleChildScrollView(
        restorationId: 'pick_destination_scroll_view',
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            sizedBoxSpace,
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                autofocus: true,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontStyle: FontStyle.italic),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Destination',
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await IGNGeoService.getSuggestions(pattern);
              },
              itemBuilder: (context, Map<String, String> suggestion) {
                return Text(suggestion['fulltext']!);
              },
              onSuggestionSelected: (Map<String, String> suggestion) {
                double lat = double.parse(suggestion['lat']!);
                double lon = double.parse(suggestion['lon']!);
                LatLng destination = LatLng(lat, lon);
                // NAVIGATION
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationPage(
                            destination: destination,
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
