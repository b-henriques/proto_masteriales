import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:test_python_api/navigationpage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:test_python_api/place.dart';
import 'package:flutter/cupertino.dart';

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
            const SizedBox(height: 10),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const TypePicker(),
          ],
        ),
      ),
    );
  }
}

const List<String> typesPrise = <String>[
  'type_ef',
  'type_2',
  'type_combo_ccs',
  'type_chademo',
  'type_autre',
];

class TypePicker extends StatefulWidget {
  const TypePicker({super.key});

  @override
  State<TypePicker> createState() => _TypePickerState();
}

class _TypePickerState extends State<TypePicker> {
  int selectedtypePrise = 0;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Text("Prise "),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(
              width: 1.0,
              color: Colors.black,
            ),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.all(5.0),
            onPressed: () => _showDialog(
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    selectedtypePrise = selectedItem;
                  });
                },
                children: List<Widget>.generate(typesPrise.length, (int index) {
                  return Center(
                    child: Text(
                      typesPrise[index],
                    ),
                  );
                }),
              ),
            ),
            child: Text(
              typesPrise[selectedtypePrise],
            ),
          ),
        ),
      ],
    );
  }
}
