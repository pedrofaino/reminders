import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/token_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
 
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen>{

  String? token;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken(context);
  }

  Future<void> _loadToken(BuildContext context) async{
    String? token = await getToken();
    if(token!=null){
      Provider.of<TokenProvider>(context, listen: false).updateToken(token);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> login() async {    
    final data = {
      "email": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await Dio().post('http://10.0.2.2:5000/api/v1/auth/login', data: data);

      Map<String, dynamic> responseData = response.data;

      String token = responseData['token'];
      int expiresIn = responseData['expiresIn'];
      String userId = responseData['userId'];

      if (token.isNotEmpty) {
        Provider.of<TokenProvider>(context, listen: false).userId = userId;
        Provider.of<TokenProvider>(context, listen: false).token = token;
        Provider.of<TokenProvider>(context, listen: false).expiresIn = expiresIn;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        print(userId);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
      appBar: AppBar(title: const Center(
          child: Row(
            children: [
          SizedBox(width: 150.0),
          Text('reminders',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFD5C7BC))),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFDEE8D5))),
          Text('.',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFE9FAE3)))
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
  return prefs.getString('token');
}

Future<void> removeToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('token');
}