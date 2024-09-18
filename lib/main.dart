import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_trial/spray_can_coordinates.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = sprayCanCoordinates['locations']!.map<Marker>((location) {
      var coords = location['coordinates']!;

      const double xScaling = 22800.0; // Scaling factor for x-axis
      const double yScaling = 22800.0; // Scaling factor for y-axis

      const double xTranslation = 0.60654771755490977103; // Translate to center the map
      const double yTranslation = 0.47454296228059800189; // Translate to center the map

      List<double> transformToMapCoords(double x, double y) {
        double transformedX = (x / xScaling) - xTranslation;
        double transformedY = (y / yScaling) + yTranslation;
        return [transformedX, transformedY];
      }

      double x = coords[0];
      double y = coords[1];

      List<double> transformedCoords = transformToMapCoords(x, y);
      double xPrime = transformedCoords[0];
      double yPrime = transformedCoords[1];

      print('primes $xPrime, $yPrime');
      return Marker(
        point: LatLng(xPrime, yPrime),
        width: 80,
        height: 80,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              crs: const CrsSimple(),
              initialCenter: const LatLng(-0.606428, 0.474673),
              initialZoom: 3.0,
              minZoom: -2.0,
              maxZoom: 7.0,
              onTap: (tapPosition, point) {
                print(
                    'Latitude: ${point.latitude.toStringAsFixed(20)}, Longitude: ${point.longitude.toStringAsFixed(20)}');
              },
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(0.0, 0.0),
                  const LatLng(-1.0, 1.0),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: //"images/tiles/{z}-{x}_{y}.png",
                    'https://raw.githubusercontent.com/mchingiz/gta_map_tiles/main/{z}_{x}_{y}.jpg',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: markers,
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                  // Also add images...
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
