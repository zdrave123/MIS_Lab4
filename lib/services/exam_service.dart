import 'package:flutter/foundation.dart';

import 'package:mis_lab4/models/exam.dart';

class ExamService with ChangeNotifier {
  List<Exam> _events = [];

  List<Exam> get events => _events;

  void addEvent(Exam event) {
    _events.add(event);
    notifyListeners();
  }

  List<Exam> getEventsForDay(DateTime day) {
    return _events.where((event) =>
    event.dateTime.year == day.year &&
        event.dateTime.month == day.month &&
        event.dateTime.day == day.day).toList();
  }
}