import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/widgets/title.dart';

class UpdateReminder extends StatefulWidget {
  final dynamic data;

  const UpdateReminder({Key? key, this.data}) : super(key: key);

  @override
  State<UpdateReminder> createState() => _UpdateReminderState();
}

class _UpdateReminderState extends State<UpdateReminder> {
  final logger = Logger();
  _UpdateReminderState();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _whenController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _date;
  DateTime? _dateWhen;
  bool? day = false;
  bool? week = false;
  Reminder? reminder;

  @override
  void initState() {
    super.initState();
    reminder = widget.data;
    _descriptionController.text = reminder?.description ?? '';
    _dateController.text = _formatDate(reminder?.date);
    _whenController.text = _formatDate(reminder?.when);
    _date = reminder?.date;
    _dateWhen = reminder?.when;
    logger.i("$_date $_dateWhen");
    day = reminder?.yesterday ?? false;
    week = reminder?.week ?? false;
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

  Future<void> updateReminder() async {
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    String? uid = Provider.of<AuthProvider>(context, listen: false).userId;
    String? token = Provider.of<AuthProvider>(context, listen: false).token;
    Object data = {
      'description': _descriptionController.text,
      'date': _date?.toIso8601String(),
      'when': _dateWhen?.toIso8601String(),
      'other': _noteController.text,
      'uid': uid,
      'yesterday': day,
      'week': week,
    };
    try {
      final response = await Dio().patch(
          '${apiConfig.url}/reminders/${reminder?.id}',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (!context.mounted) return;
      Provider.of<RemindersProvider>(context, listen: false)
          .loadReminders(context);
      context.pop();
      logger.i('Reminder updated: $response');
    } catch (e) {
      logger.e('Error in the promise for updateReminder: $e');
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
                      const Text('Actualizar Recordatorio:',
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
                          onPressed: () => updateReminder(),
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
