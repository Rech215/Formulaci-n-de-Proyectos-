import '../entities/hijo.dart';
import '../entities/padre.dart';
import '../entities/resumen_uso.dart';
import '../entities/suscripcion.dart';
import '../entities/tarea.dart';
import '../repositories/edu_guia_repository.dart';

class RegistrarPadre {
  const RegistrarPadre(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre> call({
    required String nombre,
    required String correo,
    required String password,
    List<Hijo> hijos = const <Hijo>[],
  }) {
    return _repository.registrarPadre(
      nombre: nombre,
      correo: correo,
      password: password,
      hijos: hijos,
    );
  }
}

class IniciarSesion {
  const IniciarSesion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre> call({required String correo, required String password}) {
    return _repository.iniciarSesion(correo: correo, password: password);
  }
}

class RestaurarSesion {
  const RestaurarSesion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre?> call() => _repository.restaurarSesion();
}

class CerrarSesion {
  const CerrarSesion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<void> call() => _repository.cerrarSesion();
}

class ObtenerPadre {
  const ObtenerPadre(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre> call(String padreId) => _repository.obtenerPadre(padreId);
}

class AgregarHijo {
  const AgregarHijo(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre> call(String padreId, Hijo hijo) {
    return _repository.agregarHijo(padreId, hijo);
  }
}

class EliminarHijo {
  const EliminarHijo(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Padre> call(String padreId, String nombreHijo) {
    return _repository.eliminarHijo(padreId, nombreHijo);
  }
}

class CrearTarea {
  const CrearTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call({
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
  }) {
    return _repository.crearTarea(
      padreId: padreId,
      imagenUrl: imagenUrl,
      nombreHijo: nombreHijo,
    );
  }
}

class IniciarAnalisisTarea {
  const IniciarAnalisisTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call(String tareaId) {
    return _repository.iniciarAnalisisTarea(tareaId);
  }
}

class AnalizarTarea {
  const AnalizarTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call({
    required String padreId,
    required String imagenPath,
    required String nombreHijo,
    String materiaSugerida = '',
  }) {
    return _repository.analizarTarea(
      padreId: padreId,
      imagenPath: imagenPath,
      nombreHijo: nombreHijo,
      materiaSugerida: materiaSugerida,
    );
  }
}

class CompletarAnalisisTarea {
  const CompletarAnalisisTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call(String tareaId, ResultadoAnalisis resultado) {
    return _repository.completarAnalisisTarea(tareaId, resultado);
  }
}

class MarcarErrorTarea {
  const MarcarErrorTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call(String tareaId, String mensaje) {
    return _repository.marcarErrorTarea(tareaId, mensaje);
  }
}

class ObtenerTareasPorPadre {
  const ObtenerTareasPorPadre(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<List<Tarea>> call(String padreId) {
    return _repository.obtenerTareasPorPadre(padreId);
  }
}

class ObtenerTarea {
  const ObtenerTarea(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Tarea> call(String tareaId) => _repository.obtenerTarea(tareaId);
}

class ObtenerSuscripcion {
  const ObtenerSuscripcion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Suscripcion> call(String padreId) {
    return _repository.obtenerSuscripcion(padreId);
  }
}

class ValidarSuscripcion {
  const ValidarSuscripcion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Suscripcion> call() => _repository.validarSuscripcion();
}

class ActualizarPlan {
  const ActualizarPlan(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Suscripcion> call(String padreId, TipoPlan nuevoPlan) {
    return _repository.actualizarPlan(padreId, nuevoPlan);
  }
}

class CancelarSuscripcion {
  const CancelarSuscripcion(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<Suscripcion> call(String padreId) {
    return _repository.cancelarSuscripcion(padreId);
  }
}

class PuedeConsultar {
  const PuedeConsultar(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<bool> call(String padreId) => _repository.puedeConsultar(padreId);
}

class ObtenerResumenUso {
  const ObtenerResumenUso(this._repository);

  final BaseEduGuiaRepository _repository;

  Future<ResumenUso> call(String padreId) {
    return _repository.obtenerResumenUso(padreId);
  }
}

class EduGuiaUseCases {
  EduGuiaUseCases(BaseEduGuiaRepository repository)
      : registrarPadre = RegistrarPadre(repository),
        iniciarSesion = IniciarSesion(repository),
        restaurarSesion = RestaurarSesion(repository),
        cerrarSesion = CerrarSesion(repository),
        obtenerPadre = ObtenerPadre(repository),
        agregarHijo = AgregarHijo(repository),
        eliminarHijo = EliminarHijo(repository),
        analizarTarea = AnalizarTarea(repository),
        crearTarea = CrearTarea(repository),
        iniciarAnalisisTarea = IniciarAnalisisTarea(repository),
        completarAnalisisTarea = CompletarAnalisisTarea(repository),
        marcarErrorTarea = MarcarErrorTarea(repository),
        obtenerTareasPorPadre = ObtenerTareasPorPadre(repository),
        obtenerTarea = ObtenerTarea(repository),
        obtenerSuscripcion = ObtenerSuscripcion(repository),
        validarSuscripcion = ValidarSuscripcion(repository),
        actualizarPlan = ActualizarPlan(repository),
        cancelarSuscripcion = CancelarSuscripcion(repository),
        puedeConsultar = PuedeConsultar(repository),
        obtenerResumenUso = ObtenerResumenUso(repository);

  final RegistrarPadre registrarPadre;
  final IniciarSesion iniciarSesion;
  final RestaurarSesion restaurarSesion;
  final CerrarSesion cerrarSesion;
  final ObtenerPadre obtenerPadre;
  final AgregarHijo agregarHijo;
  final EliminarHijo eliminarHijo;
  final AnalizarTarea analizarTarea;
  final CrearTarea crearTarea;
  final IniciarAnalisisTarea iniciarAnalisisTarea;
  final CompletarAnalisisTarea completarAnalisisTarea;
  final MarcarErrorTarea marcarErrorTarea;
  final ObtenerTareasPorPadre obtenerTareasPorPadre;
  final ObtenerTarea obtenerTarea;
  final ObtenerSuscripcion obtenerSuscripcion;
  final ValidarSuscripcion validarSuscripcion;
  final ActualizarPlan actualizarPlan;
  final CancelarSuscripcion cancelarSuscripcion;
  final PuedeConsultar puedeConsultar;
  final ObtenerResumenUso obtenerResumenUso;
}
