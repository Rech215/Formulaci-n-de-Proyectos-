import '../entities/hijo.dart';
import '../entities/padre.dart';
import '../entities/resumen_uso.dart';
import '../entities/suscripcion.dart';
import '../entities/tarea.dart';

/// Contrato base de acceso a datos de EduGuía.
///
/// Las implementaciones concretas son [MockEduGuiaRepository] (datos en
/// memoria) y [ApiEduGuiaRepository] (backend Node.js).
abstract class BaseEduGuiaRepository {
  Future<Padre> registrarPadre({
    required String nombre,
    required String correo,
    required String password,
    List<Hijo> hijos = const <Hijo>[],
  });

  Future<Padre> iniciarSesion({
    required String correo,
    required String password,
  });

  Future<Padre?> restaurarSesion();

  Future<void> cerrarSesion();

  Future<Padre> obtenerPadre(String padreId);

  Future<Padre> agregarHijo(String padreId, Hijo hijo);

  Future<Padre> eliminarHijo(String padreId, String nombreHijo);

  Future<Tarea> analizarTarea({
    required String padreId,
    required String imagenPath,
    required String nombreHijo,
    String materiaSugerida = '',
  });

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

  Future<Suscripcion> validarSuscripcion();

  Future<Suscripcion> actualizarPlan(String padreId, TipoPlan nuevoPlan);

  Future<Suscripcion> cancelarSuscripcion(String padreId);

  Future<bool> puedeConsultar(String padreId);

  Future<ResumenUso> obtenerResumenUso(String padreId);
}

/// Alias retrocompatible para el contrato del repositorio.
typedef EduGuiaRepository = BaseEduGuiaRepository;
