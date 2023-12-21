import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/widgets/title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  final Uri? uri;
  const ConfirmationScreen({Key? key, this.uri}) : super(key: key);
  
  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final logger = Logger();
  String? confirmationEmail;

    void showAlert(String tittle, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tittle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void handleUri (uri){
    final email = uri.queryParameters['email'];
    logger.i(email);
    confirmationEmail = email;
  }

  Future<void> confirmation(String? email) async {
    final apiProvider =
        Provider.of<ApiConfigProvider>(context, listen: false).apiConfig;
    final data = {
      "email":confirmationEmail
    };
    try {
      final response = await Dio()
          .post('${apiProvider.url}/auth/confirmationApp', data:data);

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
        context.go('/');
      } else {
        logger.e("confirmation failed");
        showAlert('Fallo el metodo de confirmación', 'Intente confrmar su email nuevamente');
      }
    } catch (e) {
      logger.e("confirmation failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    final uri = widget.uri;
    handleUri(uri);
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
            const TitleReminders(),
            const SizedBox(
              height: 50,
            ),
            const Text('Bien hecho! Ya confirmaste tu email. Presiona inicio para comenzar a utilizar la app.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () => confirmation(confirmationEmail),
                child: const Text('Inicio'))
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
