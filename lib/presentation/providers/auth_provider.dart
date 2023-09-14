import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:reminders/presentation/providers/api_provider.dart';

class User {
  final String id;
  final String email;
  final String password;
  final bool confirmed;
  final int v;
  final String name;
  final String lastName;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.confirmed,
    required this.v,
  });
}

class AuthProvider extends ChangeNotifier {
  final logger = Logger();

  bool _isAuthenticated = false;
  String? _token;
  String? _refreshToken;
  String? _userId;
  String? _email;
  int? _expiresIn;
  Timer? _refreshTokenTimer;
  Map<dynamic, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  String? get refreshToken => _refreshToken;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  int? get expiresIn => _expiresIn;
  Map<dynamic, dynamic>? get user => _user;

  set isAuthenticated(isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  set token(token) {
    _token = token;
    notifyListeners();
  }

  set refreshToken(refreshToken) {
    _refreshToken = refreshToken;
    notifyListeners();
  }

  set expiresIn(expiresIn) {
    _expiresIn = expiresIn;
    notifyListeners();
  }

  set userId(userId) {
    _userId = userId;
    notifyListeners();
  }

  set email(email) {
    _email = email;
    notifyListeners();
  }

  set user(user) {
    _user = user;
    notifyListeners();
  }

  void updateRefresh(String? newRefresh) {
    _refreshToken = newRefresh;
    notifyListeners();
  }

  void saveTokenUid(String? newToken, String? refreshToken, String? newUid,
      int newExpiresIn, BuildContext context) {
    _token = newToken;
    _refreshToken = refreshToken;
    _userId = newUid;
    _email = email;
    _expiresIn = newExpiresIn;

    notifyListeners();

    startRefreshTokenTimer(newExpiresIn, context);
  }

  void removeTokenUid() {
    _token = null;
    _expiresIn = null;
    _userId = null;
    _cancelRefreshTokenTimer();
    notifyListeners();
  }

  void startRefreshTokenTimer(int expiresIn, BuildContext context) {
    _cancelRefreshTokenTimer();
    final delay = (expiresIn * 1000) - 6000;
    _refreshTokenTimer = Timer((Duration(milliseconds: delay)),
        () => {refreshTokenFunc(context), logger.i('Refresh Token')});
  }

  void _cancelRefreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;
  }

  Future<void> refreshTokenFunc(BuildContext context) async {
    try {
      final apiConfigProvider =
          Provider.of<ApiConfigProvider>(context, listen: false);
      final apiConfig = apiConfigProvider.apiConfig;
      final response = await Dio().get('${apiConfig.url}/auth/app/refresh',
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));
      final newToken = response.data['token'];
      final newExpiresIn = response.data['expiresIn'];
      final newUserId = response.data['uid'];
      final newEmail = response.data['email'];
      email = newEmail;
      userId = newUserId;
      if (!context.mounted) return;
      saveTokenUid(newToken, refreshToken, newUserId, newExpiresIn, context);
      isAuthenticated = true;
      getInfoUser(context);
      logger.i('Refresh Token initialized');
      notifyListeners();
    } catch (e) {
      logger.e('Error refreshToken $e');
    }
  }

  Future<void> getInfoUser(BuildContext context) async {
    try {
      final apiConfigProvider =
          Provider.of<ApiConfigProvider>(context, listen: false);
      final apiConfig = apiConfigProvider.apiConfig;
      final response = await Dio().get('${apiConfig.url}/user/info/$_email',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      user = response.data;
      logger.i(user);
    } catch (e) {
      logger.e('Error getInfoUser $e');
    }
  }
}
