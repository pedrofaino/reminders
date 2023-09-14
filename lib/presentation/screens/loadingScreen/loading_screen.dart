import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/auth_provider.dart';
import 'package:reminders/presentation/screens/home/home_screen.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool isLoading = true;
  bool _isFirstBuild = true;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadToken() async {
    try {
      String? refreshToken = await getRefreshToken();
      logger.i('refresh token $refreshToken');
      if (refreshToken != null) {
        isLoading = false;
        logger.i('el refresh no es null');
        Provider.of<AuthProvider>(context, listen: false)
            .updateRefresh(refreshToken);
        await Provider.of<AuthProvider>(context, listen: false)
            .refreshTokenFunc(context);
        logger.i('ejecuto funcion refresh');
        Provider.of<AuthProvider>(context, listen: false).isAuthenticated =
            true;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        if (!context.mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } catch (e) {
      logger.e('The token loading failed: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _loadToken();
    }
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
            isLoading ? const CircularProgressIndicator() : const SizedBox(),
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
