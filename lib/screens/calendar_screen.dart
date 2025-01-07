import 'package:flutter/material.dart';
import 'package:mis_lab4/services/exam_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:mis_lab4/screens/add_exam_event_screen.dart';
import 'package:mis_lab4/screens/map_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Распоред на испити'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return context.read<ExamProvider>().getEventsForDay(day);
            },
          ),
          Expanded(
            child: Consumer<ExamProvider>(
              builder: (context, examProvider, child) {
                final events = _selectedDay != null
                    ? examProvider.getEventsForDay(_selectedDay!)
                    : [];
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.dateTime.toString()} - ${event.location}',
                      ),
                      onTap: () {
                        // Navigate to map screen with the event location
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(event: event),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}