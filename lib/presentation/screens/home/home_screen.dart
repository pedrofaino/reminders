import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:reminders/presentation/widgets/card_reminders.dart';
import 'package:reminders/presentation/widgets/custom_button.dart';
import 'package:reminders/presentation/providers/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  dynamic reminders;

  @override
  void initState(){
    super.initState();
    _checkToken();
    getReminders();
  }

  Future<void>_checkToken()async{
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final token = tokenProvider.token;
  
    if (token == null) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const  LoginScreen()));
    }
  }

  void parseAndSetReminders(Response<dynamic> response) {
  final dynamic jsonData = response.data;

  if (jsonData != null && jsonData is Map<String, dynamic> && jsonData.containsKey('reminders')) {
    final List<dynamic> remindersJson = jsonData['reminders'];
    final remindersProvider = Provider.of<RemindersProvider>(context, listen: false);
    remindersProvider.setRemindersData(remindersJson);
    print(remindersJson);
    } else {
      print('JSON no válido o sin la clave "reminders"');
    }
  }
  
  Future<void> getReminders() async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final token = tokenProvider.token;
      final response = await Dio().get('http://10.0.2.2:5000/api/v1/reminders/search?query=',
                                      data: { "uid": "649b271c7cdf3f897f79d5d7"}, 
                                      options:Options(headers: {'Authorization':'Bearer $token'}));
      parseAndSetReminders(response);  
    } catch (e) {
      print(e);
    }
    
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
  
  Future<void> logout(BuildContext context) async {
    removeToken();
    Provider.of<TokenProvider>(context,listen:false).removeToken();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Row(
            children: [
          SizedBox(width: 150.0),
          Text(
            'reminders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
          ),
          Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFD5C7BC))
          ),
          Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFDEE8D5))
          ),
          Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFE9FAE3))
          )
        ])
      )
      ),
      body: _HomeReminders(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(icon: Icons.add, onPressed: () => getReminders()),
          const SizedBox(height: 20),
          CustomButton(icon: Icons.delete, onPressed: () => logout(context)),
        ]
      ,) 
    );
  }
}

class _HomeReminders extends StatelessWidget {
  @override
  Widget build (BuildContext context){
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: CardReminders()
            )
         ]
        ),
      ) 
    );
  }
}
