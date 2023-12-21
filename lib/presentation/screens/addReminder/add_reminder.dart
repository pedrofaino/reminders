import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/widgets/title.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final logger = Logger();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _whenController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _date = DateTime.now();
  DateTime? _dateWhen = DateTime.now();
  bool? day = false;
  bool? week = false;

  @override
  void initState() {
    super.initState();
    logger.i(_date);
    logger.i(_dateWhen);
  }

  void _pickDate() async {
    final DateTime? date = await _showDatePicker();
    _date = date;
    _dateController.text = _formatDate(date);
  }

  void _pickDateW() async {
    final DateTime? date = await _showDatePicker();
    _dateWhen = date;
    _whenController.text = _formatDate(date);
  }

  Future<void> saveReminders() async {
    final remindersProvider =
        Provider.of<RemindersProvider>(context, listen: false);
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    String? uid = Provider.of<AuthProvider>(context, listen: false).userId;
    String? token = Provider.of<AuthProvider>(context, listen: false).token;
    String? email = Provider.of<AuthProvider>(context, listen: false).email;
    Object data = {
      'description': _descriptionController.text,
      'date': _date?.toIso8601String(),
      'when': _dateWhen?.toIso8601String(),
      'email': email,
      'other': _noteController.text,
      'uid': uid,
      'yesterday': day,
      'week': week,
    };
    try {
      final response = await Dio().post('${apiConfig.url}/reminders/',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      logger.i('Saved reminder: $response');
      if (!context.mounted) return;
        await remindersProvider.loadReminders(context);
      context.pop();
    } catch (e) {
      logger.e('Error in the promise for saveReminder: $e');
    }
  }

  Future<DateTime?> _showDatePicker() async {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2500));
  }

  String _formatDate(DateTime? date) {
    return "${date?.day}-${date?.month.toString().padLeft(2, '0')}-${date?.year.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.black12, title: const TitleReminders()),
        body: Column(
          children: [
            Container(
              height: 700,
              decoration: const BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nuevo Recordatorio:',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          )),
                      TextField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                      ),
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Fecha'),
                        onTap: _pickDate,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Cuando te lo recuerdo?',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Checkbox(
                            value: day,
                            onChanged: (bool? newValue) {
                              setState(() {
                                day = newValue;
                              });
                            },
                          ),
                          const Text('1 día antes'),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: week,
                            onChanged: (bool? newValue) {
                              setState(() {
                                week = newValue;
                              });
                            },
                          ),
                          const Text('1 semana antes'),
                        ],
                      ),
                      TextField(
                        controller: _whenController,
                        decoration: const InputDecoration(
                            labelText: 'Fecha en específico'),
                        onTap: _pickDateW,
                      ),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Nota'),
                      ),
                    ]),
              )),
            ),
            Expanded(
                child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Descartar',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20)))),
                  Expanded(
                      child: TextButton(
                          onPressed: () => saveReminders(),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          )))
                ],
              ),
            ))
          ],
        ));
  }
}
