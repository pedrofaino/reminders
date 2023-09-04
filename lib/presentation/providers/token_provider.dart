import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  int? _expiresIn;

  String? get token => _token;
  String? get userId => _userId;
  int? get expiresIn => _expiresIn;

  void updateToken(String? newToken) {
    _token = newToken;
    notifyListeners();
  }

  void removeToken(){
    _token = null;
    _expiresIn = null;
    notifyListeners();
  }
  
  set token(String? newToken) {
    _token = newToken;
    notifyListeners();
  }
  
  set userId(String? newUserId) {
    _userId = newUserId;
    notifyListeners();
  }
  
  set expiresIn(int? newToken) {
    _expiresIn = newToken;
    notifyListeners();
  }
}