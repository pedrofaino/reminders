import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String? _token;
  String? _refreshToken;
  String? _userId;
  int? _expiresIn;
  Timer? _refreshTokenTimer;

  String? get refreshToken => _refreshToken;
  String? get token => _token;
  String? get userId => _userId;
  int? get expiresIn => _expiresIn;

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

  set userId(userId){
    _userId = userId;
    notifyListeners();
  }

  void updateToken(String? newToken) {
    _token = newToken;
    notifyListeners();
  }

  void saveTokenUid(String? newToken, String? refreshToken , String? newUid, int newExpiresIn) {
    _token = newToken;
    _refreshToken = refreshToken;
    _userId = newUid;
    _expiresIn = newExpiresIn;

    notifyListeners();

    startRefreshTokenTimer(newExpiresIn);
  }

  void removeTokenUid() {
    _token = null;
    _expiresIn = null;
    _userId = null;
    _cancelRefreshTokenTimer();
    notifyListeners();
  }

  void startRefreshTokenTimer(int expiresIn) {
    _cancelRefreshTokenTimer();
    final delay = (expiresIn * 1000) - 6000;
    _refreshTokenTimer =
        Timer((Duration(milliseconds: delay)), () => {
          refreshTokenFunc(), print('ejecuto refresh token')});
  }

  Future<void> refreshTokenFunc() async {
    try {
      final response =
          await Dio().get('http://10.0.2.2:5000/api/v1/auth/app/refresh',
              options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'}));
      final newToken = response.data['token'];
      final newExpiresIn = response.data['expiresIn'];
      token = newToken;
      expiresIn = newExpiresIn;
      notifyListeners();
    } catch (e) {
      print('Error en el refresh${e}');
    }
  }

  void _cancelRefreshTokenTimer() {
    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;
  }
}
