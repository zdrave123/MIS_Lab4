import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final List<Marker> markers; // Accepting List<Marker>

  MapScreen(this.markers); // Constructor now accepts List<Marker>

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: markers.isNotEmpty
              ? markers[0].position
              : LatLng(0.0, 0.0), // Default if no markers
          zoom: 10,
        ),
        markers: Set<Marker>.from(markers), // Pass markers as Set
      ),
    );
  }
}


