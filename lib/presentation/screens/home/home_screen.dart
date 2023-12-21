import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/config/deep_links.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/widgets/card_reminders.dart';
import 'package:reminders/presentation/widgets/custom_button.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/widgets/loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    initURIHandler(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated == true) {
        await Provider.of<RemindersProvider>(context, listen: false)
            .loadReminders(context);
        setState(() {          
          isLoading = false;
        });
      } else {
        context.go('/login');
      }
    });
  }

  Future<void> removeToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('refreshToken');
  }

  Future<void> logout(BuildContext context) async {
    removeToken();
    Provider.of<AuthProvider>(context, listen: false).removeTokenUid();
    Provider.of<AuthProvider>(context, listen: false).isAuthenticated = false;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
                child: Row(children: [
              const Text('reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
              const Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFD5C7BC))),
              const Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFDEE8D5))),
              const Text('.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFFE9FAE3))),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'action2',
                            child: Text('Mi cuenta'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'action1',
                            child: Text('Cerrar sesión'),
                          ),
                        ];
                      },
                      onSelected: (String result) {
                        if (result == 'action1') {
                          logout(context);
                        }
                        if (result == 'action2') {
                          context.push('/myAccount');
                        }
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Cuenta',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 17),
                          ),
                          Icon(Icons.more_vert),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]))),
        body:
            isLoading ? const Center(child: LoadingWidget()) : _HomeReminders(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
                icon: Icons.add, onPressed: () => context.push('/addReminder')),
          ],
        ));
  }
}

class _HomeReminders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(children: [Expanded(child: CardReminders())]),
    ));
  }
}
