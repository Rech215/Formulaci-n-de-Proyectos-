/// Contrato del contador local de consultas gratuitas.
///
/// La implementación vive en `data/services/local_usage_service.dart` y usa
/// `shared_preferences`, de modo que el límite sobrevive al cierre de la app.
abstract class LocalUsageRepository {
  /// Consultas gratuitas con las que arranca cada usuario nuevo.
  static const int consultasGratuitasIniciales = 5;

  /// Devuelve las consultas restantes del usuario. Si es la primera vez,
  /// inicializa el contador con [consultasGratuitasIniciales].
  Future<int> obtenerRestantes(String usuarioId);

  /// Resta una consulta al usuario (sin bajar de cero) y devuelve el nuevo
  /// valor persistido.
  Future<int> consumir(String usuarioId);

  /// Restablece el contador a [consultasGratuitasIniciales].
  Future<void> reiniciar(String usuarioId);
}
