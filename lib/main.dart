import 'package:flutter/material.dart';
import 'package:reminders/config/theme/api_config.dart';
import 'package:reminders/config/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/loadingScreen/loading_screen.dart';
import 'package:logger/logger.dart';


Future <void> main() async {
  Logger.level = Level.debug;

  final apiConfigProvider = ApiConfigProvider();
  apiConfigProvider.updateApiConfig(ApiConfig.production());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => RemindersProvider()),
    ChangeNotifierProvider(create: (context) => ApiConfigProvider()),
    ChangeNotifierProvider.value(value: apiConfigProvider)
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 1).theme(),
      home: const LoadingPage(),
    );
  }
}
