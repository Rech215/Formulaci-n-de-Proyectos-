import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import '../../domain/entities/resumen_uso.dart';
import '../../domain/entities/suscripcion.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/pagos_repository.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required EduGuiaUseCases useCases,
    PagosRepository? pagosRepository,
  })  : _useCases = useCases,
        _pagosRepository = pagosRepository;

  static const bool _demoAutoLoginConfigurado = bool.fromEnvironment(
    'EDUGUIA_DEMO_AUTO_LOGIN',
    defaultValue: true,
  );

  static const String _demoCorreo = 'demo@eduguia.mx';
  static const String _demoPassword = 'demo12345';

  bool get _demoAutoLogin => _demoAutoLoginConfigurado;

  final EduGuiaUseCases _useCases;
  final PagosRepository? _pagosRepository;

  Padre? _padre;
  Suscripcion? _suscripcion;
  List<Tarea> _tareas = const <Tarea>[];
  ResumenUso? _resumen;
  bool _cargando = false;
  bool _inicializado = false;
  String? _error;
  DomainException? _errorExcepcion;

  Padre? get padre => _padre;
  Suscripcion? get suscripcion => _suscripcion;
  List<Tarea> get tareas => List<Tarea>.unmodifiable(_tareas);
  ResumenUso? get resumen => _resumen;
  bool get cargando => _cargando;
  bool get inicializado => _inicializado;
  String? get error => _error;
  DomainException? get errorExcepcion => _errorExcepcion;
  bool get haySesion => _padre != null;
  bool get puedeConsultar => _suscripcion?.puedeConsultar() ?? false;

  Future<void> initialize() async {
    if (_inicializado || _cargando) return;

    _cargando = true;
    _error = null;
    _errorExcepcion = null;
    notifyListeners();

    try {
      final restaurado = await _useCases.restaurarSesion.call();

      if (restaurado != null) {
        _padre = restaurado;
      } else if (_demoAutoLogin) {
        _padre = await _iniciarSesionDemo();
      }

      if (_padre != null) {
        await _refrescar(_padre!.id, notificar: false);
      }
      _inicializado = true;
    } on DomainException catch (error) {
      _errorExcepcion = error;
      _error = error.message;
    } catch (_) {
      const error = DomainException('No fue posible iniciar la sesión.');
      _errorExcepcion = error;
      _error = error.message;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Padre> _iniciarSesionDemo() async {
    try {
      return await _useCases.iniciarSesion(
        correo: _demoCorreo,
        password: _demoPassword,
      );
    } on DomainException {
      return _useCases.registrarPadre(
        nombre: 'Familia Demo',
        correo: _demoCorreo,
        password: _demoPassword,
        hijos: <Hijo>[
          Hijo(nombre: 'Mateo', edad: 9, gradoEscolar: '4to Primaria'),
        ],
      );
    }
  }

  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    await _ejecutar(() async {
      final padre = await _useCases.iniciarSesion(
        correo: correo,
        password: password,
      );
      _padre = padre;
      await _refrescar(padre.id, notificar: false);
      _inicializado = true;
    });
  }

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String password,
    List<Hijo> hijos = const <Hijo>[],
  }) async {
    await _ejecutar(() async {
      final padre = await _useCases.registrarPadre(
        nombre: nombre,
        correo: correo,
        password: password,
        hijos: hijos,
      );
      _padre = padre;
      await _refrescar(padre.id, notificar: false);
      _inicializado = true;
    });
  }

  Future<void> cerrarSesion() async {
    await _ejecutar(() async {
      await _useCases.cerrarSesion.call();
      _padre = null;
      _suscripcion = null;
      _tareas = const <Tarea>[];
      _resumen = null;
    });
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

  Future<void> comprarPremium() async {
    final padre = _padre;
    final pagos = _pagosRepository;
    if (padre == null) return;

    if (pagos == null) {
      const error = DomainException(
        'La compra integrada no está disponible en esta versión.',
      );
      _errorExcepcion = error;
      _error = error.message;
      notifyListeners();
      return;
    }

    await _ejecutar(() async {
      await pagos.inicializar(appUserId: padre.id);
      final suscripcion = await pagos.comprarPremium();
      if (suscripcion != null) {
        _suscripcion = suscripcion;
      }
      await _refrescar(padre.id, notificar: false);
    });
  }

  Future<void> restaurarCompras() async {
    final padre = _padre;
    final pagos = _pagosRepository;
    if (padre == null) return;

    if (pagos == null) {
      const error = DomainException(
        'La restauración de compras no está disponible.',
      );
      _errorExcepcion = error;
      _error = error.message;
      notifyListeners();
      return;
    }

    await _ejecutar(() async {
      await pagos.inicializar(appUserId: padre.id);
      final suscripcion = await pagos.restaurarCompras();
      if (suscripcion != null) {
        _suscripcion = suscripcion;
      }
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

  Future<void> recargar() async {
    final padre = _padre;
    if (padre == null) return;
    await _ejecutar(() => _refrescar(padre.id, notificar: false));
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    _errorExcepcion = null;
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
    _errorExcepcion = null;
    notifyListeners();

    try {
      await accion();
    } on DomainException catch (error) {
      _errorExcepcion = error;
      _error = error.message;
    } catch (_) {
      const error = DomainException('Ocurrió un error inesperado.');
      _errorExcepcion = error;
      _error = error.message;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
