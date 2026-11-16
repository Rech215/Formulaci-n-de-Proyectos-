/// Contrato del control local de escaneos diarios.
///
/// El límite depende del plan (Gratis o Premium) y se reinicia cada día. La
/// implementación local usa `shared_preferences`, por lo que el contador vive
/// únicamente en el dispositivo.
abstract class ScanQuotaRepository {
  /// Devuelve cuántos escaneos lleva el padre en el día actual.
  Future<int> obtenerUsadosHoy(String padreId);

  /// Registra un escaneo y devuelve el total acumulado del día.
  Future<int> registrarEscaneo(String padreId);

  /// Reinicia el contador del padre para el día actual.
  Future<void> reiniciar(String padreId);
}
