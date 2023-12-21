import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/config/deep_links.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/widgets/google_button.dart';
import 'package:reminders/presentation/widgets/title.dart';
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
  bool obscureText = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initURIHandler(context);
    WidgetsFlutterBinding.ensureInitialized();
  }

  void mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la alerta
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
          await Dio().post('${apiConfig.url}/auth/loginApp', data: data);
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
        logger.e("Login failed");
      }
    } catch (e) {
      logger.e(e);
      if (e is DioException) {
        final int? statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          mostrarAlerta("Credenciales incorrectas",
              "Por favor revise su usuario y contraseña");
        } else if (statusCode == 403) {
          mostrarAlerta("Usuario no confirmado",
              "El email del usuario que intenta iniciar sesión no esta confirmado, por favor revise su correo electronico para confirmarlo.");
        } else {
          mostrarAlerta("Error", "Error en el inicio de sesión");
        }
      } else {
        logger.e("Login failed: $e");
        mostrarAlerta("Error", "Error en el inicio de sesión");
      }
    }
  }

  Future<void> loginGoogle() async {
    final apiConfigProvider =
        Provider.of<ApiConfigProvider>(context, listen: false);
    final apiConfig = apiConfigProvider.apiConfig;
    const devKey =
        '711797277116-s2sivp74an1vc72onfp8dn9pcv6ioc4t.apps.googleusercontent.com';
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: devKey,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          'openid',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
      try {
        final googleUserAccount = await googleSignIn.signIn();
        final googleAuth = await googleUserAccount?.authentication;
        if (googleAuth != null) {
          final response = await Dio()
              .get('${apiConfig.url}/auth/session/auth0/googleApp', data: {
            'access_token': googleAuth.accessToken,
            'id_token': googleAuth.idToken
          });
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
            logger.e("Login failed");
          }
        }
      } catch (error) {
        logger.e(error);
      }
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TitleReminders()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    child: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      semanticLabel: obscureText
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                    ),
                  )),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(),
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: '¿No tienes una cuenta? ',
                style: const TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Regístrate',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.goNamed('register');
                        }),
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            GoogleSignInButton(onPressed: () => loginGoogle())
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
