import '../../core/errors/domain_exception.dart';
import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import '../../domain/entities/resumen_uso.dart';
import '../../domain/entities/suscripcion.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/edu_guia_repository.dart';

class InMemoryEduGuiaRepository implements EduGuiaRepository {
  final Map<String, Padre> _padres = <String, Padre>{};
  final Map<String, Tarea> _tareas = <String, Tarea>{};
  final Map<String, Suscripcion> _suscripciones = <String, Suscripcion>{};
  int _contadorId = 0;

  String _generarId(String prefijo) {
    _contadorId++;
    return '${prefijo}_${DateTime.now().microsecondsSinceEpoch}_$_contadorId';
  }

  @override
  Future<Padre> registrarPadre({
    required String nombre,
    required String correo,
    List<Hijo> hijos = const <Hijo>[],
  }) async {
    final correoNormalizado = correo.trim().toLowerCase();
    final correoExistente = _padres.values.any(
      (padre) => padre.correo == correoNormalizado,
    );
    if (correoExistente) {
      throw DomainException(
        'Ya existe una cuenta registrada con el correo "$correo".',
      );
    }

    final padreId = _generarId('padre');
    final padre = Padre(
      id: padreId,
      nombre: nombre,
      correo: correo,
      hijos: hijos,
    );
    _padres[padreId] = padre;

    final suscripcion = Suscripcion(
      id: _generarId('sub'),
      padreId: padreId,
      tipoPlan: TipoPlan.gratuito,
    );
    _suscripciones[padreId] = suscripcion;

    return padre;
  }

  @override
  Future<Padre> obtenerPadre(String padreId) async {
    return _buscarPadre(padreId);
  }

  @override
  Future<Padre> agregarHijo(String padreId, Hijo hijo) async {
    final padre = _buscarPadre(padreId);
    final actualizado = padre.agregarHijo(hijo);
    _padres[padreId] = actualizado;
    return actualizado;
  }

  @override
  Future<Padre> eliminarHijo(String padreId, String nombreHijo) async {
    final padre = _buscarPadre(padreId);
    final actualizado = padre.eliminarHijo(nombreHijo);
    _padres[padreId] = actualizado;
    return actualizado;
  }

  @override
  Future<Tarea> crearTarea({
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
  }) async {
    _buscarPadre(padreId);
    final suscripcion = _buscarSuscripcion(padreId);

    if (!suscripcion.puedeConsultar()) {
      throw const DomainException(
        'Has alcanzado el límite de consultas de tu plan. '
        'Actualiza a Premium para consultas ilimitadas.',
      );
    }

    _suscripciones[padreId] = suscripcion.registrarConsulta();

    final tarea = Tarea(
      id: _generarId('tarea'),
      padreId: padreId,
      imagenUrl: imagenUrl,
      nombreHijo: nombreHijo,
    );
    _tareas[tarea.id] = tarea;
    return tarea;
  }

  @override
  Future<Tarea> iniciarAnalisisTarea(String tareaId) async {
    final tarea = _buscarTarea(tareaId);
    final actualizada = tarea.iniciarAnalisis();
    _tareas[tareaId] = actualizada;
    return actualizada;
  }

  @override
  Future<Tarea> completarAnalisisTarea(
    String tareaId,
    ResultadoAnalisis resultado,
  ) async {
    final tarea = _buscarTarea(tareaId);
    final actualizada = tarea.completarAnalisis(resultado);
    _tareas[tareaId] = actualizada;
    return actualizada;
  }

  @override
  Future<Tarea> marcarErrorTarea(String tareaId, String mensaje) async {
    final tarea = _buscarTarea(tareaId);
    final actualizada = tarea.marcarError(mensaje);
    _tareas[tareaId] = actualizada;
    return actualizada;
  }

  @override
  Future<List<Tarea>> obtenerTareasPorPadre(String padreId) async {
    _buscarPadre(padreId);
    final tareas = _tareas.values
        .where((tarea) => tarea.padreId == padreId)
        .toList(growable: false);
    tareas.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return tareas;
  }

  @override
  Future<Tarea> obtenerTarea(String tareaId) async {
    return _buscarTarea(tareaId);
  }

  @override
  Future<Suscripcion> obtenerSuscripcion(String padreId) async {
    return _buscarSuscripcion(padreId);
  }

  @override
  Future<Suscripcion> actualizarPlan(
    String padreId,
    TipoPlan nuevoPlan,
  ) async {
    final padre = _buscarPadre(padreId);
    final suscripcion = _buscarSuscripcion(padreId);

    final suscripcionActualizada = suscripcion.actualizarPlan(nuevoPlan);
    final padreActualizado = padre.actualizarPlan(nuevoPlan);

    _suscripciones[padreId] = suscripcionActualizada;
    _padres[padreId] = padreActualizado;

    return suscripcionActualizada;
  }

  @override
  Future<Suscripcion> cancelarSuscripcion(String padreId) async {
    final padre = _buscarPadre(padreId);
    final suscripcion = _buscarSuscripcion(padreId);

    final suscripcionCancelada = suscripcion.cancelar();
    final padreActualizado = padre.actualizarPlan(TipoPlan.gratuito);

    _suscripciones[padreId] = suscripcionCancelada;
    _padres[padreId] = padreActualizado;

    return suscripcionCancelada;
  }

  @override
  Future<bool> puedeConsultar(String padreId) async {
    return _buscarSuscripcion(padreId).puedeConsultar();
  }

  @override
  Future<ResumenUso> obtenerResumenUso(String padreId) async {
    final padre = _buscarPadre(padreId);
    final suscripcion = _buscarSuscripcion(padreId);
    final tareas = await obtenerTareasPorPadre(padreId);

    return ResumenUso(
      nombrePadre: padre.nombre,
      plan: suscripcion.tipoPlan,
      consultasUsadas: suscripcion.consultasUsadas,
      consultasRestantes: suscripcion.consultasRestantes,
      totalTareas: tareas.length,
      tareasCompletadas: tareas
          .where((tarea) => tarea.estado == EstadoTarea.completada)
          .length,
      cantidadHijos: padre.hijos.length,
    );
  }

  Padre _buscarPadre(String padreId) {
    final padre = _padres[padreId];
    if (padre == null) {
      throw DomainException('Padre con ID "$padreId" no encontrado.');
    }
    return padre;
  }

  Tarea _buscarTarea(String tareaId) {
    final tarea = _tareas[tareaId];
    if (tarea == null) {
      throw DomainException('Tarea con ID "$tareaId" no encontrada.');
    }
    return tarea;
  }

  Suscripcion _buscarSuscripcion(String padreId) {
    final suscripcion = _suscripciones[padreId];
    if (suscripcion == null) {
      throw DomainException(
        'Suscripción para el padre "$padreId" no encontrada.',
      );
    }
    return suscripcion;
  }
}
