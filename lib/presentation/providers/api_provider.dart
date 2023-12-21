import 'package:flutter/material.dart';
import 'package:reminders/config/api_config.dart';


class ApiConfigProvider extends ChangeNotifier {
  ApiConfig _apiConfig = ApiConfig.defaultConfig();

  ApiConfig get apiConfig => _apiConfig;

  void updateApiConfig(ApiConfig newConfig) {
    _apiConfig = newConfig;
    notifyListeners();
  }
}