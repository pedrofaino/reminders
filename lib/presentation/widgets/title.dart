import 'package:flutter/material.dart';

class TitleReminders extends StatelessWidget {
  const TitleReminders({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'reminders',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
        ),
        Text(
          '.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xFFD5C7BC),
          ),
        ),
        Text(
          '.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xFFDEE8D5),
          ),
        ),
        Text(
          '.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xFFE9FAE3),
          ),
        ),
      ],
    );
  }
}
