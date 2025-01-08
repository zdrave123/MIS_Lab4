import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mis_lab4/models/exam.dart';
import 'package:mis_lab4/services/exam_service.dart';

class AddExamScreen extends StatefulWidget {
  final DateTime initialDate;

  const AddExamScreen({Key? key, required this.initialDate}) : super(key: key);

  @override
  _AddExamScreenState createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();

    _selectedDate = widget.initialDate;

    _selectedLocation = LatLng(42.0047, 21.4091);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveExam(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      final exam = Exam(
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

      context.read<ExamService>().addEvent(exam);
      Navigator.pop(context);
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildTextField(
              controller: _titleController,
              labelText: 'Course Name',
              icon: Icons.book,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter the course name' : null,
            ),
            SizedBox(height: 16.0),
            _buildTextField(
              controller: _locationController,
              labelText: 'Location',
              icon: Icons.location_on,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter the location' : null,
            ),
            SizedBox(height: 16.0),
            _buildDatePickerTile(context),
            SizedBox(height: 8.0),
            _buildTimePickerTile(context),
            SizedBox(height: 16.0),
            _buildMap(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _saveExam(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Save', style: TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePickerTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
      title: Text(
        'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
        style: TextStyle(fontSize: 16.0),
      ),
      trailing: Icon(Icons.edit),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildTimePickerTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
      title: Text(
        'Time: ${_selectedTime.format(context)}',
        style: TextStyle(fontSize: 16.0),
      ),
      trailing: Icon(Icons.edit),
      onTap: () => _selectTime(context),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: FlutterMap(
          options: MapOptions(
            center: _selectedLocation!,
            zoom: 13.0,
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
                    child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

