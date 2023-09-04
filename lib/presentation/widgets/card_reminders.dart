import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';

class CardReminders extends StatelessWidget{  
  final List<String> entries = <String>['A', 'B', 'C', 'D', 'F'];

  @override
  Widget build(BuildContext context) {
    final remindersProvider = Provider.of<RemindersProvider>(context, listen: false);
    final remindersData = remindersProvider.remindersData;
    return ListView.separated(
      padding: const EdgeInsets.all(6),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 150,
          color: const Color(0xF5F5F5F5),
          child: Row(
            children:[
              const SizedBox(width: 10.5),
              SizedBox(
                width: 50.0,
                height: 50.0,
                child: Image.asset('assets/calendar.png')
                ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    'Fecha: 20-12-23',
                    style: TextStyle(color: Colors.black),), 
                  Text('Descripción: Casamiento Ibai ${remindersData}'),
                ],
              ),
            ]),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

