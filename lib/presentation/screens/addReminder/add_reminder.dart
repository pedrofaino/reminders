import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
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
    String? uid = Provider.of<AuthProvider>(context, listen: false).userId;
    String? token = Provider.of<AuthProvider>(context, listen: false).token;
    Object data = {
      'description': _descriptionController.text,
      'date': _dateController.text,
      'when': _whenController.text,
      'other': _noteController.text,
      'uid': uid,
      'yesterday': day,
      'week': week,
    };
    final response = await Dio().post('http://10.0.2.2:5000/api/v1/reminders/',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    
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
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.black12,
            title: const Center(
                child: Row(children: [
              SizedBox(width: 150.0),
              Text('reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFD5C7BC))),
              Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFDEE8D5))),
              Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFE9FAE3)))
            ]))),
        body: Column(
          children: [
            Container(
              height: 650,
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
                          onPressed: () => saveReminders(),
                          child: const Text('Guardar',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20)))),
                   Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                          child: const Text(
                            'Descartar',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          )))
                ],
              ),
            ))
          ],
        ));
  }
}
