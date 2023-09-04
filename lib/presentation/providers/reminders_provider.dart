import 'package:flutter/material.dart';

class RemindersData {
  final List<dynamic> reminders;

  RemindersData({required this.reminders});
}

class RemindersProvider extends ChangeNotifier {
  RemindersData? _remindersData;

  RemindersData? get remindersData => _remindersData;

  void setRemindersData(List<dynamic> reminders) {
    _remindersData = RemindersData(reminders: reminders);
    notifyListeners();
  }
}