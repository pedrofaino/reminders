import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';

class RemindersData {
  final List<Reminder> reminders;

  RemindersData({required this.reminders});
}

class RemindersProvider extends ChangeNotifier {
  RemindersData? _remindersData;
  final logger = Logger();
  RemindersData? get remindersData => _remindersData;

  parseAndSetReminders(Response<dynamic> response) {
    logger.i('entro al parse');
    final dynamic jsonData = response.data;
    if (jsonData != null &&
        jsonData is Map<String, dynamic> &&
        jsonData.containsKey('reminders')) {
      final List<dynamic> remindersJson = jsonData['reminders'];
      final List<Reminder> reminders = remindersJson.map((json) {
        return Reminder(
          id: json["_id"],
          description: json["description"],
          date: DateTime.parse(json["date"]),
          when: DateTime.parse(json["when"]),
          other: json["other"],
          yesterday: json["yesterday"],
          week: json["week"],
          uid: json["uid"],
          v: json["__v"],
        );
      }).toList();
      logger.i(reminders);
      logger.i('tamanio');
      logger.i(reminders.length);
      return reminders;
    } else {
      logger.e('JSON no valid without key "reminders"');
    }
  }

  Future<void> loadReminders(BuildContext context) async {
    logger.i('entro');
    logger.i(context);
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    // if (!context.mounted) return;
    try {
      logger.i('entro al try');
      final tokenProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = tokenProvider.token;
      final uid = tokenProvider.userId;
      final response = await Dio().get(
          '${apiConfig.url}/reminders/search?query=',
          data: {"uid": uid},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (context.mounted) {
        final remindersProvider =
            Provider.of<RemindersProvider>(context, listen: false);
        remindersProvider.setRemindersData(parseAndSetReminders(response));
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error in the promise for getReminders $e');
    }
  }

  void setRemindersData(List<Reminder> reminders) {
    try {
      _remindersData = RemindersData(reminders: reminders);
      notifyListeners();
    } catch (e) {
      logger.e('error en el setReminders $e');
    }
  }
}

class Reminder {
  final String id;
  final String description;
  final DateTime date;
  final DateTime when;
  final String other;
  final bool? yesterday;
  final bool? week;
  final String uid;
  final int v;

  Reminder({
    required this.id,
    required this.description,
    required this.date,
    required this.when,
    required this.other,
    this.yesterday,
    this.week,
    required this.uid,
    required this.v,
  });
}
