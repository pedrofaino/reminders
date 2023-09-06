import 'package:flutter/material.dart';


class AddReminder extends StatefulWidget {
  
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}


class _AddReminderState extends State<AddReminder>{

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _whenController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _date = DateTime.now();
  DateTime? _dateW = DateTime.now();

  @override
  void initState(){
    super.initState();
  }

  void _pickDate() async {
    final DateTime? date = await _showDatePicker();
    _date = date;
    print(_date);
    _dateController.text = _formatDate(date);
  }

  void _pickDateW() async {
    final DateTime? date = await _showDatePicker();
    _dateW = date;
    print(_dateW);
    _whenController.text = _formatDate(date);
  }

  Future <DateTime?> _showDatePicker() async{
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2500)
    );  
  }

  String _formatDate(DateTime? date) {
    return "${date?.day}-${date?.month.toString().padLeft(2, '0')}-${date?.year.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Row(
            children: [
          SizedBox(width: 150.0),
          Text('reminders',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFD5C7BC))),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFDEE8D5))),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFE9FAE3)))])
          )),
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha'),
              onTap: _pickDate,
            ),
            TextField(
              controller: _whenController,
              decoration: const InputDecoration(labelText: 'Cuando te lo recuerdo'),
              onTap: _pickDateW,
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Nota'),
            ),
         ]
        ),
      ) 
    ));
  }
}