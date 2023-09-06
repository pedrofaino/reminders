import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/reminders_provider.dart';
import 'package:reminders/presentation/screens/addReminder/add_reminder.dart';
import 'package:reminders/presentation/screens/login/login_screen.dart';
import 'package:reminders/presentation/widgets/card_reminders.dart';
import 'package:reminders/presentation/widgets/custom_button.dart';
import 'package:reminders/presentation/providers/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
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
      final List<Reminder> reminders = remindersJson .map((json) {
        return Reminder(
          id: json["_id"],
          description: json["description"],
          date: DateTime.parse(json["date"]),
          when: DateTime.parse(json["when"]),
          other: json["other"],
          yesterday: json["yesterday"],
          week: json["week"],
          uid: json["uid"],
          v: json["__v"],
        );
        }).toList();
      remindersProvider.setRemindersData(reminders);
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
      print('Error en la obtencion del reminder ${e}');
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

    String dropdownValue = list.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            children: [
          const SizedBox(width: 20.0),
          const Text(
            'reminders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
          ),
          const Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFD5C7BC))
          ),
          const Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFDEE8D5))
          ),
          const Text(
            '.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,color: Color(0xFFE9FAE3))
          ),
          const SizedBox(
            width: 185.0,
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'action1',
                  child: Text('Cerrar sesión'),
                ),
              ];
            },
            onSelected: (String result) {
              if(result == 'action1'){
                logout(context);
              }
            },
            child: const  Row(
              children: [
                Text('Mi perfil', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),),
                Icon(Icons.more_vert),
              ],
            ),
          ),
        ])
      )
      ),
      body: _HomeReminders(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(icon: Icons.add, onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AddReminder()))),
        ]
      ,) 
    );
  }
}

class _HomeReminders extends StatelessWidget {
  @override
  Widget build (BuildContext context){
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8.0),
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
