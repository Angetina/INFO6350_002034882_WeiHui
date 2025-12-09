import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps Codelab',
      debugShowCheckedModeBanner: false,
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _center = LatLng(37.7749, -122.4194); // San Francisco
  final _markers = {
    const Marker(
      markerId: MarkerId('sf'),
      position: _center,
      infoWindow: InfoWindow(title: 'San Francisco'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps in Flutter (iOS)')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _center, zoom: 12),
        markers: _markers,
      ),
    );
  }
}
