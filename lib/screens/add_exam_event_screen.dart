import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mis_lab4/models/exam_event.dart';
import 'package:mis_lab4/services/exam_service.dart';


class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    // Set default location to Skopje city center
    _selectedLocation = LatLng(42.0047, 21.4091);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Додади нов испит'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Име на предмет'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ве молиме внесете име на предметот';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Локација'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ве молиме внесете локација';
                }
                return null;
              },
            ),
            // Date picker
            ListTile(
              title: Text('Датум: ${_selectedDate.toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2025),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            // Time picker
            ListTile(
              title: Text('Време: ${_selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
            ),
            // Preview map for location selection
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 16.0),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selectedLocation!,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: _selectedLocation!,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && _selectedLocation != null) {
                  final event = ExamEvent(
                    id: DateTime.now().toString(),
                    title: _titleController.text,
                    dateTime: DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    ),
                    location: _selectedLocation!,
                    locationName: _locationController.text,
                  );

                  context.read<ExamProvider>().addEvent(event);
                  Navigator.pop(context);
                }
              },
              child: Text('Зачувај'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}