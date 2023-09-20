import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final logger = Logger();
  String? email;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<void> register() async {
    final apiProvider =
        Provider.of<ApiConfigProvider>(context, listen: false).apiConfig;
    if (_passwordController.text != _rePasswordController.text) {
      mostrarAlerta(
          'Error en la contraseña', 'Las contraseñas deben ser iguales');
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
        mostrarAlerta('Registro exitoso',
            '¡Tu registro ha sido exitoso! Se ha enviado un mail tu correo para confirmarlo.');
      } else {
        mostrarAlerta('Error de registro', 'Hubo un error al registrar.');
      }
    } catch (e) {
      logger.e(e);
    }
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
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
                  color: Color(0xFFE9FAE3))),
        ]))),
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
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                TextField(
                  controller: _rePasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Repita la contraseña'),
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
