import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  dynamic user;

  @override
  void initState() {
    super.initState();
    user = Provider.of<AuthProvider>(context, listen: false).user;
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('refreshToken');
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
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                  ),
                  Icon(Icons.more_vert),
                ],
              ),
            ),
          ]))),
      body: _MyAccount(user: user),
    );
  }
}

class _MyAccount extends StatelessWidget {
  final dynamic user;
  final TextEditingController name;
  final TextEditingController lastName;
  final TextEditingController email;

  _MyAccount({required this.user})
      : name = TextEditingController(text: user['name'] ?? ''),
        lastName = TextEditingController(text: user['lastName'] ?? ''),
        email = TextEditingController(text: user['email'] ?? '');

  @override
  Widget build(BuildContext context) {
    Future<void> updateUser() async {
      Object data = {
        "name": name.text,
        "lastName": lastName.text,
        "email": email.text,
      };
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final uid = Provider.of<AuthProvider>(context, listen: false).userId;
      final response = await Dio().patch(
          'http://10.0.2.2:5000/api/v1/user/user/$uid',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      print(response);
    }

    return Column(children: [
      SizedBox(
          height: 650,
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(100.0),
            child: Column(children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
            ]),
          ))),
      Expanded(
          child: Container(
              color: Colors.white,
              child: Row(children: [
                Expanded(
                    child: TextButton(
                        onPressed: () => updateUser(),
                        child: const Text('Guardar',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)))),
                Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen())),
                        child: const Text(
                          'Descartar',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )))
              ])))
    ]);
  }
}
