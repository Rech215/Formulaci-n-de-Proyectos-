import '../entities/tarea.dart';

/// Contrato del historial local de tareas escaneadas.
///
/// Permite repasar el método SEP y las preguntas guía sin depender del
/// servidor. La implementación temporal usa `shared_preferences` con JSON.
abstract class HistorialRepository {
  /// Devuelve las tareas guardadas del padre, de la más reciente a la más
  /// antigua. Nunca lanza por datos corruptos: los descarta.
  Future<List<Tarea>> obtener(String padreId);

  /// Guarda o reemplaza una tarea en el historial local.
  Future<void> guardar(String padreId, Tarea tarea);

  /// Elimina una tarea del historial local.
  Future<void> eliminar(String padreId, String tareaId);

  /// Borra todo el historial local del padre.
  Future<void> limpiar(String padreId);
}
