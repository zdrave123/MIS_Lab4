import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mis_lab4/models/exam_event.dart';

class MapScreen extends StatefulWidget {
  final ExamEvent event;

  MapScreen({required this.event});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are denied.'),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      if (_currentPosition != null) {
        await _getRoute();

        // Adjust map bounds to show both points
        _fitBounds();
      }
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
        ),
      );
    }
  }

  void _fitBounds() {
    if (_currentPosition != null && widget.event.location != null) {
      final bounds = LatLngBounds(
        LatLng(
          min(_currentPosition!.latitude, widget.event.location.latitude),
          min(_currentPosition!.longitude, widget.event.location.longitude),
        ),
        LatLng(
          max(_currentPosition!.latitude, widget.event.location.latitude),
          max(_currentPosition!.longitude, widget.event.location.longitude),
        ),
      );

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds),
      );
    }
  }



  Future<void> _getRoute() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      // Using OSRM demo server - for production, you should use your own server
      final response = await http.get(Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/'
              '${_currentPosition!.longitude},${_currentPosition!.latitude};'
              '${widget.event.location.longitude},${widget.event.location.latitude}'
              '?overview=full&geometries=geojson'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

          setState(() {
            _routePoints = coordinates
                .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      print('Error getting route: $e');
      // Fallback to straight line if route calculation fails
      setState(() {
        _routePoints = [
          _currentPosition!,
          widget.event.location,
        ];
      });
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Локација на испит'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.event.location,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  // Exam location marker
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: widget.event.location,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  // Current location marker (if available)
                  if (_currentPosition != null)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _currentPosition!,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                ],
              ),
              // Draw route line if both points are available
              if (_routePoints.length == 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 3.0,
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoadingRoute)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}