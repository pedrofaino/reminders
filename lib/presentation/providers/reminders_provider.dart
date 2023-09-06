import 'package:flutter/material.dart';

class RemindersData {
  final List<Reminder> reminders;

  RemindersData({required this.reminders});
}

class RemindersProvider extends ChangeNotifier {
  RemindersData? _remindersData;

  RemindersData? get remindersData => _remindersData;

  void setRemindersData(List<Reminder> reminders) {
    _remindersData = RemindersData(reminders: reminders);
    notifyListeners();
  }
}
class Reminder {
  final String id;
  final String description;
  final DateTime date;
  final DateTime when;
  final String other;
  final bool yesterday;
  final bool week;
  final String uid;
  final int v;

  Reminder({
    required this.id,
    required this.description,
    required this.date,
    required this.when,
    required this.other,
    required this.yesterday,
    required this.week,
    required this.uid,
    required this.v,
  });
}