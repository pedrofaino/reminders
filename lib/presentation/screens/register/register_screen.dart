import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/config/deep_links.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:reminders/presentation/widgets/title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final logger = Logger();
  String? email;
  bool obscureText = true;
  bool obscureTextRe = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initURIHandler(context);
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<void> register() async {
    final apiProvider =
        Provider.of<ApiConfigProvider>(context, listen: false).apiConfig;
    if (_passwordController.text != _rePasswordController.text) {
      showAlert('Error en la contraseña', 'Las contraseñas deben ser iguales');
      return;
    }
    final data = {
      'email': _usernameController.text,
      'password': _passwordController.text,
      'repassword': _rePasswordController.text,
    };

    logger.i(data);
    try {
      final response =
          await Dio().post('${apiProvider.url}/auth/registerApp', data: data);
      logger.i(response);
      if (response.statusCode == 201) {
        showAlert('Registro exitoso',
            '¡Tu registro ha sido exitoso! Se ha enviado un mail tu correo para confirmarlo.');
      } else {
        showAlert('Error de registro', 'Hubo un error al registrar.');
      }
    } catch (e) {
      logger.e(e);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const TitleReminders()),
        body: Column(children: [
          const SizedBox(
            height: 90,
          ),
          const Text(
            'Registro',
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Email'),
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
                TextFormField(
                  controller: _rePasswordController,
                  obscureText: obscureTextRe,
                  decoration: InputDecoration(
                      labelText: 'Repite la contraseña',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscureTextRe = !obscureTextRe;
                          });
                        },
                        child: Icon(
                          obscureTextRe
                              ? Icons.visibility
                              : Icons.visibility_off,
                          semanticLabel: obscureTextRe
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => register(),
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ]));
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
