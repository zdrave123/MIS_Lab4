import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mis_lab4/screens/calendar_screen.dart';
import 'package:mis_lab4/screens/directions_screen.dart';
import 'package:mis_lab4/screens/map_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

List<Marker> getMarkers() {
  final examEvents = [
    {'id': '1', 'lat': 41.9981, 'lng': 21.4254, 'title': 'Exam 1'},
    {'id': '2', 'lat': 41.6086, 'lng': 21.7453, 'title': 'Exam 2'},
  ];

  return examEvents.map((event) {
    return Marker(
      markerId: MarkerId(event['id'] as String),
      position: LatLng(event['lat'] as double, event['lng'] as double),
      infoWindow: InfoWindow(title: event['title'] as String),
    );
  }).toList();
}


class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;



  final _screens = [
    CalendarScreen(),
    MapScreen(getMarkers()), // Pass markers list
    DirectionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.directions), label: 'Directions'),
        ],
      ),
    );
  }
}
