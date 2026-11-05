import '../entities/hijo.dart';
import '../entities/padre.dart';
import '../entities/resumen_uso.dart';
import '../entities/suscripcion.dart';
import '../entities/tarea.dart';

abstract class EduGuiaRepository {
  Future<Padre> registrarPadre({
    required String nombre,
    required String correo,
    List<Hijo> hijos = const <Hijo>[],
  });

  Future<Padre> obtenerPadre(String padreId);

  Future<Padre> agregarHijo(String padreId, Hijo hijo);

  Future<Padre> eliminarHijo(String padreId, String nombreHijo);

  Future<Tarea> crearTarea({
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
  });

  Future<Tarea> iniciarAnalisisTarea(String tareaId);

  Future<Tarea> completarAnalisisTarea(
    String tareaId,
    ResultadoAnalisis resultado,
  );

  Future<Tarea> marcarErrorTarea(String tareaId, String mensaje);

  Future<List<Tarea>> obtenerTareasPorPadre(String padreId);

  Future<Tarea> obtenerTarea(String tareaId);

  Future<Suscripcion> obtenerSuscripcion(String padreId);

  Future<Suscripcion> actualizarPlan(String padreId, TipoPlan nuevoPlan);

  Future<Suscripcion> cancelarSuscripcion(String padreId);

  Future<bool> puedeConsultar(String padreId);

  Future<ResumenUso> obtenerResumenUso(String padreId);
}
