import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
    } catch (_) {
      // El archivo .env es opcional: se usan los valores por defecto.
    }
  }

  static String? _env(String key) {
    try {
      final value = dotenv.maybeGet(key);
      if (value == null || value.trim().isEmpty) return null;
      return value.trim();
    } catch (_) {
      return null;
    }
  }

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    final fromEnv = _env('API_URL');
    if (fromEnv != null) return fromEnv;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  static bool get useMocks {
    const override = String.fromEnvironment('EDUGUIA_USAR_MOCK');
    if (override.isNotEmpty) return override.toLowerCase() == 'true';

    final fromEnv = _env('USE_MOCKS');
    if (fromEnv != null) return fromEnv.toLowerCase() == 'true';

    return false;
  }

  static Duration get timeout {
    const override = int.fromEnvironment(
      'API_TIMEOUT_SECONDS',
      defaultValue: 0,
    );
    if (override > 0) return const Duration(seconds: override);

    final fromEnv = int.tryParse(_env('API_TIMEOUT_SECONDS') ?? '');
    return Duration(seconds: fromEnv ?? 60);
  }
}
