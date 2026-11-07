import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/local_usage_repository.dart';

/// Contador de consultas gratuitas persistido con `shared_preferences`.
///
/// Cada usuario (padre) tiene su propia clave para que el límite no se mezcle
/// entre cuentas del mismo dispositivo.
class LocalUsageService implements LocalUsageRepository {
  static const String _prefijo = 'eduguia_consultas_restantes_';

  String _clave(String usuarioId) => '$_prefijo$usuarioId';

  @override
  Future<int> obtenerRestantes(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final clave = _clave(usuarioId);
    final guardado = prefs.getInt(clave);

    if (guardado == null) {
      await prefs.setInt(
        clave,
        LocalUsageRepository.consultasGratuitasIniciales,
      );
      return LocalUsageRepository.consultasGratuitasIniciales;
    }

    return guardado < 0 ? 0 : guardado;
  }

  @override
  Future<int> consumir(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final clave = _clave(usuarioId);
    final actual =
        prefs.getInt(clave) ?? LocalUsageRepository.consultasGratuitasIniciales;
    final restantes = actual > 0 ? actual - 1 : 0;

    await prefs.setInt(clave, restantes);
    return restantes;
  }

  @override
  Future<void> reiniciar(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _clave(usuarioId),
      LocalUsageRepository.consultasGratuitasIniciales,
    );
  }
}
