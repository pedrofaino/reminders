import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/widgets/show_alert.dart';

class CardReminders extends StatefulWidget {
  const CardReminders({Key? key}) : super(key: key);

  @override
  State<CardReminders> createState() => _CardRemindersState();
}

class _CardRemindersState extends State<CardReminders> {
  final logger = Logger();
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
          if (!context.mounted) return;
          remindersProvider.loadReminders(context);
          logger.i('Reminder deleted $response');
        } catch (e) {
          logger.e('Error in the promise for deleteReminder $e');
        }
      }

      RichText shortString(String cad) {
        final input = cad.substring(0, 50);
        return RichText(
            text: TextSpan(
                text: input,
                style: const TextStyle(color: Colors.black, fontSize: 17),
                children: [
              TextSpan(
                  text: '... ver más',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showAlert(context, 'Descripcíon', cad);
                    }),
            ]));
      }

      return ListView.separated(
        padding: const EdgeInsets.all(6),
        itemCount: reminders.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                context.pushNamed('update', extra: reminders[index]);
              },
              child: Container(
                  height: 150,
                  color: const Color(0xF5F5F5F5),
                  child: Row(children: [
                    Expanded(
                        flex: 1,
                        child: SafeArea(
                            child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${parseDateDay('${reminders[index].date}')}',
                                  style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${parseDateMonth('${reminders[index].date}')}',
                                style: const TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ))),
                    Expanded(
                      flex: 4,
                      child: SafeArea(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  reminders[index].description.length < 50
                                      ? Text(
                                          'Descripción: ${reminders[index].description}',
                                          style: const TextStyle(fontSize: 17))
                                      : shortString(
                                          reminders[index].description),
                                  Text(
                                      'Recordarme el: ${parseDate('${reminders[index].when}')}',
                                      style: const TextStyle(fontSize: 17)),
                                  Text(
                                      'Algo que pense: ${reminders[index].other}',
                                      style: const TextStyle(fontSize: 17)),
                                ])
                          ])),
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            deleteReminder(reminders[index].id),
                                        icon: const Icon(Icons.delete))
                                  ])
                            ]))
                  ])));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      );
    });
  }
}
