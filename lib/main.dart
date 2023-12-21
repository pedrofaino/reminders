import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reminders/config/api_config.dart';
import 'package:reminders/config/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reminders/config/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:logger/logger.dart';
import 'config/router_config.dart';
import 'config/deep_links.dart';

void main() async {
  Logger.level = Level.debug;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  final apiConfigProvider = ApiConfigProvider();
  apiConfigProvider.updateApiConfig(ApiConfig.developmentPhone());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => RemindersProvider()),
    ChangeNotifierProvider(create: (context) => ApiConfigProvider()),
    ChangeNotifierProvider.value(value: apiConfigProvider)
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final logger = Logger();
  GoRouter router = createRouter();

  @override
  void initState() {
    super.initState();
    initURIHandler(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reminders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 1).theme(),
      routerConfig: router,
    );
  }
}
