import 'package:flutter/material.dart';
import 'package:reminders/config/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/token_provider.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';

void main() {

  runApp(
    MultiProvider(providers: [ChangeNotifierProvider(create: (context) => TokenProvider()),ChangeNotifierProvider(create: (context) => RemindersProvider())],
    child: const MyApp()
    )
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme( selectedColor: 1).theme(),
      home: const LoginScreen(),
    );
  }
}
