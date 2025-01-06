import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsScreen extends StatefulWidget {
  @override
  _DirectionsScreenState createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  final List<LatLng> _routeCoordinates = [
    LatLng(41.9981, 21.4254), // Start location
    LatLng(41.9951, 21.4316), // Destination
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shortest Route')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _routeCoordinates.first,
          zoom: 14,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: _routeCoordinates,
            color: Colors.blue,
            width: 5,
          )
        },
        markers: _routeCoordinates
            .map((e) => Marker(markerId: MarkerId(e.toString()), position: e))
            .toSet(),
      ),
    );
  }
}
