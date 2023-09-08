import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final remindersProvider =
        Provider.of<RemindersProvider>(context, listen: false);
    final List<Reminder> reminders =
        remindersProvider.remindersData?.reminders ?? [];
    Future <void> deleteReminder(id) async {
    try {
      final token = Provider.of<AuthProvider>(context,listen: false).token;
      final response = await Dio().delete('http://10.0.2.2:5000/api/v1/reminders/$id',
                      options: Options(headers: {
                  'Authorization': 'Bearer $token'
                },));
    } catch (e) {
      print(e);
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
                          width: 50.0,
                          height: 50.0,
                          child: Image.asset('assets/calendar.png')))),
              SafeArea(
                  child: SizedBox(
                      width: 339.2,
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30.0),
                                Text(
                                  'Fecha: ${parseDate('${reminders[index].date}')}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                    'Descripción: ${reminders[index].description}'),
                                Text(
                                    'Recordarme el: ${parseDate('${reminders[index].when}')}'),
                                Text(
                                    'Algo que pense: ${reminders[index].other}'),
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
                                        builder: (context) =>
                                            UpdateReminder(data : reminders[index]))),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () => deleteReminder(reminders[index].id),
                                icon: const Icon(Icons.delete))
                          ])))
            ]));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
