import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:reminders/presentation/widgets/google_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final logger = Logger();
  String? token;
  bool? isAuthenticated;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<void> login() async {
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    final data = {
      "email": _usernameController.text,
      "password": _passwordController.text,
    };
    try {
      final response =
          await Dio().post('${apiConfig.url}/auth/login', data: data);

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
        logger.e("Login failed");
      }
    } catch (e) {
      logger.e("Login failed: $e");
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
            const SizedBox(height: 20),
            GoogleSignInButton(onPressed: () => googleLogin())
          ],
        ),
      ),
    );
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
