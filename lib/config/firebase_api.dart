import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Tittle: ${message.notification?.title}');
  logger.i('body: ${message.notification?.body}');
  logger.i('Payload: ${message.data}');
}

class FirebaseApi {
  final logger = Logger();
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    logger.i('token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
