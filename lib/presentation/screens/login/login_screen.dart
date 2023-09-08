import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  String? token;
  bool? isAuthenticated;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken(context);
  }

  Future<void> _loadToken(BuildContext context) async {
    String? refreshToken = await getRefreshToken();
    if (refreshToken != null) {
      Provider.of<AuthProvider>(context, listen: false)
          .updateRefresh(refreshToken);
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .refreshTokenFunc();
        isAuthenticated =
            Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
        isAuthenticated = true;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> login() async {
    final data = {
      "email": _usernameController.text,
      "password": _passwordController.text,
    };

    final localContext = context;

    try {
      final response = await Dio()
          .post('http://10.0.2.2:5000/api/v1/auth/login', data: data);

      Map<String, dynamic> responseData = response.data;

      dynamic refreshToken = responseData['refreshToken'];
      String token = responseData['token'];
      int expiresIn = responseData['expiresIn'];
      String userId = responseData['userId'];

      if (token.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('refreshToken', refreshToken);
        isAuthenticated =
            Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
        isAuthenticated = true;
        Provider.of<AuthProvider>(localContext, listen: false)
            .saveTokenUid(token, refreshToken, userId, expiresIn);
        Navigator.pushReplacement(localContext,
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        print("Inicio de sesión fallido");
      }
    } catch (e) {
      print("Error durante el inicio de sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Row(children: [
        SizedBox(width: 150.0),
        Text('reminders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        Text('.',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color(0xFFD5C7BC))),
        Text('.',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color(0xFFDEE8D5))),
        Text('.',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color(0xFFE9FAE3)))
      ]))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
}

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refreshToken');
}

Future<void> removeToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
}

Future<void> saveRefreshToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('refreshToken', token);
}

Future<String?> getRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refreshToken');
}

Future<void> removeRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('refreshToken');
}
