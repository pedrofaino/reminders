class ApiConfig {
  final String url;

  ApiConfig({required this.url});

  factory ApiConfig.developmentPhone() {
    return ApiConfig(url: 'http://192.168.0.1/api/v1');
  }

  factory ApiConfig.development() {
    return ApiConfig(url: 'http://10.0.2.2:5000/api/v1');
  }

  factory ApiConfig.production() {
    return ApiConfig(url: 'https://reminders-services.onrender.com/api/v1');
  }

  factory ApiConfig.defaultConfig() {
    return ApiConfig(url: 'http://10.0.2.2:5000/api/v1');
  }
}
