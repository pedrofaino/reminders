import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/updateReminder/update_reminder.dart';

class CardReminders extends StatelessWidget {
  const CardReminders({
    super.key,
  });

  String parseDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String dayMonth = DateFormat('dd-MM').format(dateTime);
    return dayMonth;
  }

  String parseDateDay(String date) {
    DateTime dateTime = DateTime.parse(date);
    String dayMonth = DateFormat('dd').format(dateTime);
    return dayMonth;
  }

  String parseDateMonth(String date) {
    DateTime dateTime = DateTime.parse(date);
    String dayMonth = DateFormat('MM').format(dateTime);
    return dayMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RemindersProvider>(
        builder: (context, remindersProvider, child) {
      final logger = Logger();
      final apiConfigProvider =
          Provider.of<ApiConfigProvider>(context, listen: false);
      final apiConfig = apiConfigProvider.apiConfig;
      final remindersProvider =
          Provider.of<RemindersProvider>(context, listen: false);
      final List<Reminder> reminders =
          remindersProvider.remindersData?.reminders ?? [];
      Future<void> deleteReminder(id) async {
        try {
          final token = Provider.of<AuthProvider>(context, listen: false).token;
          final response = await Dio().delete('${apiConfig.url}/reminders/$id',
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
              ));
          logger.i('Reminder deleted $response');
        } catch (e) {
          logger.e('Error in the promise for deleteReminder $e');
        }
      }

      return ListView.separated(
        padding: const EdgeInsets.all(6),
        itemCount: reminders.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              height: 150,
              color: const Color(0xF5F5F5F5),
              child: Row(children: [
                SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: 70.0,
                          height: 115.0,
                          child: Column(
                            children: [
                              Text(
                                  '${parseDateDay('${reminders[index].date}')}',
                                  style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${parseDateMonth('${reminders[index].date}')}',
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ))),
                SafeArea(
                    child: SizedBox(
                        width: 315.2,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 27.0),
                                  Text(
                                      'Descripción: ${reminders[index].description}',
                                      style: TextStyle(fontSize: 17)),
                                  Text(
                                      'Recordarme el: ${parseDate('${reminders[index].when}')}',
                                      style: TextStyle(fontSize: 17)),
                                  Text(
                                      'Algo que pense: ${reminders[index].other}',
                                      style: TextStyle(fontSize: 17)),
                                ])))),
                SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(2.4),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UpdateReminder(
                                              data: reminders[index]))),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () =>
                                      deleteReminder(reminders[index].id),
                                  icon: const Icon(Icons.delete))
                            ])))
              ]));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      );
    });
  }
}
