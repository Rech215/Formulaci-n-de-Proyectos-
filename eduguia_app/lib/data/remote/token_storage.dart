import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> leer();

  Future<void> guardar(String token);

  Future<void> borrar();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _clave = 'eduguia_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> leer() => _storage.read(key: _clave);

  @override
  Future<void> guardar(String token) {
    return _storage.write(key: _clave, value: token);
  }

  @override
  Future<void> borrar() => _storage.delete(key: _clave);
}

class MemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> leer() async => _token;

  @override
  Future<void> guardar(String token) async {
    _token = token;
  }

  @override
  Future<void> borrar() async {
    _token = null;
  }
}
