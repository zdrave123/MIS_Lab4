import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mis_lab4/models/exam.dart';

class MapScreen extends StatefulWidget {
  final Exam event;

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
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnackBar('Location services are disabled. Please enable them.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!await _handleLocationPermission()) return;

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
        _fitBounds();
      }
    } catch (e) {
      _showSnackBar('Failed to get current location: $e');
    }
  }

  void _fitBounds() {
    if (_currentPosition == null || widget.event.location == null) return;

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

    _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
            '${_currentPosition!.longitude},${_currentPosition!.latitude};'
            '${widget.event.location.longitude},${widget.event.location.latitude}'
            '?overview=full&geometries=geojson',
      ));

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
      setState(() {
        _routePoints = [_currentPosition!, widget.event.location];
      });
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam location'),
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
