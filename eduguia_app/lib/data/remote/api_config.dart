import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const String _baseUrlDefinida = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_baseUrlDefinida.isNotEmpty) return _baseUrlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }
    return 'http://127.0.0.1:4000/api';
  }
}
