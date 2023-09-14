import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/screens/addReminder/add_reminder.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:reminders/presentation/screens/myAccount/my_account.dart';
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
  dynamic reminders;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated == true) {
        getReminders().then((_) => {
              if (mounted)
                {
                  setState(() {
                    isLoading = false;
                  })
                }
            });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  parseAndSetReminders(Response<dynamic> response) {
    final dynamic jsonData = response.data;
    if (jsonData != null &&
        jsonData is Map<String, dynamic> &&
        jsonData.containsKey('reminders')) {
      final List<dynamic> remindersJson = jsonData['reminders'];
      final List<Reminder> reminders = remindersJson.map((json) {
        return Reminder(
          id: json["_id"],
          description: json["description"],
          date: DateTime.parse(json["date"]),
          when: DateTime.parse(json["when"]),
          other: json["other"],
          yesterday: json["yesterday"],
          week: json["week"],
          uid: json["uid"],
          v: json["__v"],
        );
      }).toList();
      return reminders;
    } else {
      logger.e('JSON no valid without key "reminders"');
    }
  }

  Future<void> getReminders() async {
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    if (!context.mounted) return;
    try {
      final tokenProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = tokenProvider.token;
      final uid = tokenProvider.userId;
      final response = await Dio().get(
          '${apiConfig.url}/reminders/search?query=',
          data: {"uid": uid},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (!context.mounted) return;
      final remindersProvider =
          Provider.of<RemindersProvider>(context, listen: false);
      remindersProvider.setRemindersData(parseAndSetReminders(response));
      logger.i(remindersProvider.remindersData);
    } catch (e) {
      logger.e('Error in the promise for getReminders $e');
    }
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
                child: Row(children: [
              const SizedBox(width: 20.0),
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
              const SizedBox(
                width: 185.0,
              ),
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyAccountScreen()));
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
            ]))),
        body:
            isLoading ? const Center(child: LoadingWidget()) : _HomeReminders(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
                icon: Icons.add,
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddReminder()))),
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
