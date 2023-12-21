import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/screens/addReminder/add_reminder.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:reminders/presentation/screens/loadingScreen/loading_screen.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:reminders/presentation/screens/myAccount/my_account.dart';
import 'package:reminders/presentation/screens/register/confirmation_screen.dart';
import 'package:reminders/presentation/screens/register/register_screen.dart';
import 'package:reminders/presentation/screens/updateReminder/update_reminder.dart';

GoRouter createRouter() {
  return GoRouter(
      initialLocation: '/loading',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
            routes: [
              GoRoute(
                  name: 'update',
                  path: 'update',
                  builder: (context, state) {
                    Reminder reminder = state.extra as Reminder;
                    return UpdateReminder(data: reminder);
                  }),
              GoRoute(
                  name:'addReminder',
                  path: 'addReminder',
                  builder: (context, state) => const AddReminder()),
            ]),
        GoRoute(
            path: '/loading',
            builder: (context, state) => const LoadingScreen()),
        GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
            routes: [
              GoRoute(
                  name: 'register',
                  path: 'register',
                  builder: (context, state) => const RegisterScreen(),
                  routes: [
                    GoRoute(
                      path: 'confirmation',
                      name: 'confirmation',
                      builder: (context, state) {
                        Uri uri = state.extra as Uri;
                        return ConfirmationScreen(uri: uri);
                      },
                    )
                  ]),
            ]),
        GoRoute(
            path: '/myAccount',
            builder: (context, state) => const MyAccountScreen()),
      ]);
}
