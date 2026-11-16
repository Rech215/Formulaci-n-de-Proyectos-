import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/scan_quota_repository.dart';

/// Cuota diaria de escaneos almacenada en `shared_preferences`.
///
/// El contador se asocia a cada padre y se reinicia automáticamente cuando
/// cambia la fecha local, sin necesidad de conexión ni de un proceso externo.
class ScanQuotaService implements ScanQuotaRepository {
  ScanQuotaService({DateTime Function()? ahora})
      : _ahora = ahora ?? DateTime.now;

  static const String _prefijoFecha = 'eduguia_escaneos_fecha_';
  static const String _prefijoUsados = 'eduguia_escaneos_usados_';

  final DateTime Function() _ahora;

  String _claveFecha(String padreId) => '$_prefijoFecha$padreId';
  String _claveUsados(String padreId) => '$_prefijoUsados$padreId';

  String get _fechaActual {
    final fecha = _ahora();
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  @override
  Future<int> obtenerUsadosHoy(String padreId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_claveFecha(padreId)) != _fechaActual) {
      await _guardar(prefs, padreId, 0);
      return 0;
    }
    return prefs.getInt(_claveUsados(padreId)) ?? 0;
  }

  @override
  Future<int> registrarEscaneo(String padreId) async {
    final prefs = await SharedPreferences.getInstance();
    final usados = prefs.getString(_claveFecha(padreId)) == _fechaActual
        ? prefs.getInt(_claveUsados(padreId)) ?? 0
        : 0;
    final total = usados + 1;
    await _guardar(prefs, padreId, total);
    return total;
  }

  @override
  Future<void> reiniciar(String padreId) async {
    final prefs = await SharedPreferences.getInstance();
    await _guardar(prefs, padreId, 0);
  }

  Future<void> _guardar(
    SharedPreferences prefs,
    String padreId,
    int usados,
  ) async {
    await prefs.setString(_claveFecha(padreId), _fechaActual);
    await prefs.setInt(_claveUsados(padreId), usados);
  }
}
