import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import '../../domain/entities/resumen_uso.dart';
import '../../domain/entities/suscripcion.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({required EduGuiaUseCases useCases}) : _useCases = useCases;

  final EduGuiaUseCases _useCases;

  Padre? _padre;
  Suscripcion? _suscripcion;
  List<Tarea> _tareas = const <Tarea>[];
  ResumenUso? _resumen;
  bool _cargando = false;
  bool _inicializado = false;
  String? _error;

  Padre? get padre => _padre;

  Suscripcion? get suscripcion => _suscripcion;

  List<Tarea> get tareas => List<Tarea>.unmodifiable(_tareas);

  ResumenUso? get resumen => _resumen;

  bool get cargando => _cargando;

  bool get inicializado => _inicializado;

  String? get error => _error;

  bool get haySesion => _padre != null;

  bool get puedeConsultar => _suscripcion?.puedeConsultar() ?? false;

  Future<void> initialize() async {
    if (_inicializado || _cargando) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final padre = await _useCases.registrarPadre(
        nombre: 'Familia Demo',
        correo: 'demo@eduguia.mx',
        hijos: <Hijo>[
          Hijo(nombre: 'Mateo', edad: 9, gradoEscolar: '4to Primaria'),
        ],
      );
      _padre = padre;
      await _refrescar(padre.id, notificar: false);
      _inicializado = true;
    } on DomainException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'No fue posible iniciar la sesión de demostración.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregarHijo({
    required String nombre,
    required int edad,
    required String gradoEscolar,
  }) async {
    final padre = _padre;
    if (padre == null) return;

    await _ejecutar(() async {
      final hijo = Hijo(
        nombre: nombre,
        edad: edad,
        gradoEscolar: gradoEscolar,
      );
      await _useCases.agregarHijo(padre.id, hijo);
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> eliminarHijo(String nombreHijo) async {
    final padre = _padre;
    if (padre == null) return;

    await _ejecutar(() async {
      await _useCases.eliminarHijo(padre.id, nombreHijo);
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> actualizarPlan(TipoPlan nuevoPlan) async {
    final padre = _padre;
    if (padre == null) return;

    await _ejecutar(() async {
      await _useCases.actualizarPlan(padre.id, nuevoPlan);
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> cancelarSuscripcion() async {
    final padre = _padre;
    if (padre == null) return;

    await _ejecutar(() async {
      await _useCases.cancelarSuscripcion(padre.id);
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> simularEscaneo({required String nombreHijo}) async {
    final padre = _padre;
    if (padre == null) return;

    await _ejecutar(() async {
      final tarea = await _useCases.crearTarea(
        padreId: padre.id,
        imagenUrl:
            'https://images.eduguia.mx/demo/tarea-${DateTime.now().millisecondsSinceEpoch}.jpg',
        nombreHijo: nombreHijo,
      );
      final analizando = await _useCases.iniciarAnalisisTarea(tarea.id);
      await _useCases.completarAnalisisTarea(
        analizando.id,
        ResultadoAnalisis(
          materia: 'Matemáticas',
          temaDetectado: 'Fracciones equivalentes',
          metodoSep:
              'La SEP introduce el tema con material concreto, representaciones '
              'gráficas y la recta numérica antes de llegar a la regla numérica.',
          preguntasGuia: const <String>[
            '¿Qué representa cada parte de la tarea?',
            '¿Puedes dibujarlo o usar un objeto de casa para explicarlo?',
            '¿Qué pasaría si cambias el orden o el tamaño de las partes?',
          ],
        ),
      );
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> recargar() async {
    final padre = _padre;
    if (padre == null) return;
    await _ejecutar(() => _refrescar(padre.id, notificar: false));
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> _refrescar(String padreId, {bool notificar = true}) async {
    _padre = await _useCases.obtenerPadre(padreId);
    _suscripcion = await _useCases.obtenerSuscripcion(padreId);
    _tareas = await _useCases.obtenerTareasPorPadre(padreId);
    _resumen = await _useCases.obtenerResumenUso(padreId);
    if (notificar) notifyListeners();
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await accion();
    } on DomainException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Ocurrió un error inesperado.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
