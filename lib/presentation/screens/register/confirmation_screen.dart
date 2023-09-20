import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final logger = Logger();
  String? confirmationEmail;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

   Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      logger.i('llego aca $link');
    });
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      final uri = Uri.parse(initialLink);
      logger.i(uri.queryParameters['email']);
      if(uri.queryParameters['email'] != null){
        String? email = uri.queryParameters['email'];
        confirmationEmail = email;
      }
    }
   } 

  Future<void> confirmation(String? email) async {
    final apiProvider =
        Provider.of<ApiConfigProvider>(context, listen: false).apiConfig;
    try {
      final response =
          await Dio().post('${apiProvider.url}/auth/confirmationApp',data:email);

      Map<String, dynamic> responseData = response.data;

      dynamic refreshToken = responseData['refreshToken'];
      String token = responseData['token'];
      int expiresIn = responseData['expiresIn'];
      String userId = responseData['userId'];

      if (token.isNotEmpty) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('token', token);
        pref.setString('refreshToken', refreshToken);
        if (!context.mounted) return;
        Provider.of<AuthProvider>(context, listen: false).isAuthenticated =
            true;
        Provider.of<AuthProvider>(context, listen: false)
            .saveTokenUid(token, refreshToken, userId, expiresIn, context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        logger.e("confirmation failed");
      }
    } catch (e) {
      logger.e("confirmation failed: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color(0xFFBCDFDF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reminders',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.black),
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
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
                'Su cuenta fue confirmada, para ir al inicio precione el siguiente boton'),
            ElevatedButton(
                onPressed: () => confirmation(confirmationEmail), child: Text('Inicio'))
          ],
        ),
      ),
    ));
  }
}

Future<void> saveToken(String token) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('token', token);
}

Future<String?> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('refreshToken');
}

Future<void> removeToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove('token');
}

Future<void> saveRefreshToken(String token) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString('refreshToken', token);
}

Future<String?> getRefreshToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('refreshToken');
}

Future<void> removeRefreshToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove('refreshToken');
}
