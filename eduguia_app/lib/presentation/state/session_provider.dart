import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../data/services/scan_quota_service.dart';
import '../../domain/entities/hijo.dart';
import '../../domain/entities/padre.dart';
import '../../domain/entities/resumen_uso.dart';
import '../../domain/entities/suscripcion.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/pagos_repository.dart';
import '../../domain/repositories/scan_quota_repository.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required EduGuiaUseCases useCases,
    PagosRepository? pagosRepository,
    ScanQuotaRepository? scanQuotaRepository,
  })  : _useCases = useCases,
        _pagosRepository = pagosRepository,
        _scanQuotaRepository = scanQuotaRepository ?? ScanQuotaService();

  final EduGuiaUseCases _useCases;
  final PagosRepository? _pagosRepository;
  final ScanQuotaRepository _scanQuotaRepository;

  Padre? _padre;
  Suscripcion? _suscripcion;
  List<Tarea> _tareas = const <Tarea>[];
  ResumenUso? _resumen;
  bool _cargando = false;
  bool _inicializado = false;
  bool _sesionSimulada = false;
  bool _cuotaCargada = false;
  int _escaneosUsadosHoy = 0;
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
  bool get esPremium => _suscripcion?.esPremium ?? false;
  bool get puedeConsultar => _suscripcion?.puedeConsultar() ?? false;

  int get escaneosUsadosHoy => _escaneosUsadosHoy;
  bool get cuotaCargada => _cuotaCargada;
  int get limiteEscaneosDiarios => esPremium
      ? Suscripcion.escaneosDiariosPremium
      : Suscripcion.escaneosDiariosGratis;
  int get escaneosRestantesHoy =>
      math.max(0, limiteEscaneosDiarios - _escaneosUsadosHoy);
  bool get puedeEscanearHoy => escaneosRestantesHoy > 0;

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
      }

      if (_padre != null) {
        await _refrescar(_padre!.id, notificar: false);
      } else {
        _cuotaCargada = false;
        _escaneosUsadosHoy = 0;
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

  Future<bool> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      _cargando = true;
      _error = null;
      _errorExcepcion = null;
      notifyListeners();

      // Simulación de red estricta e independiente del repositorio.
      await Future<void>.delayed(const Duration(seconds: 2));

      // Fuerza el éxito para probar la UI sin depender de get_it.
      _montarSesionSimulada(
        nombre: _nombreDesdeCorreo(correo),
        correo: correo,
      );
      await _cargarCuotaDiaria(_claveCuota(_padre!), notificar: false);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error en login: $e\n$stackTrace');
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    try {
      _cargando = true;
      _error = null;
      _errorExcepcion = null;
      notifyListeners();

      // Simulación de red estricta e independiente del repositorio.
      await Future<void>.delayed(const Duration(seconds: 2));

      // Fuerza el éxito para probar la UI sin depender de get_it.
      _montarSesionSimulada(nombre: nombre, correo: correo);
      await _cargarCuotaDiaria(_claveCuota(_padre!), notificar: false);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error en registro: $e\n$stackTrace');
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _ejecutar(() async {
      await _useCases.cerrarSesion.call();
      _padre = null;
      _suscripcion = null;
      _tareas = const <Tarea>[];
      _resumen = null;
      _sesionSimulada = false;
      _cuotaCargada = false;
      _escaneosUsadosHoy = 0;
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
      final hijo = Hijo(nombre: nombre, edad: edad, gradoEscolar: gradoEscolar);
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

    if (_sesionSimulada) {
      await _ejecutar(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        final actual = _suscripcion ??
            Suscripcion(id: 'sub_${padre.id}', padreId: padre.id);
        _suscripcion =
            actual.esPremium ? actual : actual.actualizarPlan(TipoPlan.premium);
        _padre = padre.actualizarPlan(TipoPlan.premium);
        await _cargarCuotaDiaria(_claveCuota(padre), notificar: false);
      });
      return;
    }

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

    if (_sesionSimulada) {
      if (_suscripcion?.esPremium ?? false) {
        await _cargarCuotaDiaria(_claveCuota(padre));
        return;
      }
      const error = DomainException(
        'No encontramos una compra Premium activa en este dispositivo.',
      );
      _errorExcepcion = error;
      _error = error.message;
      notifyListeners();
      return;
    }

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

  Future<void> cargarCuotaDiaria() async {
    final padre = _padre;
    if (padre == null) {
      _cuotaCargada = false;
      _escaneosUsadosHoy = 0;
      notifyListeners();
      return;
    }
    await _cargarCuotaDiaria(_claveCuota(padre));
  }

  Future<bool> registrarEscaneoHoy() async {
    final padre = _padre;
    if (padre == null || !puedeEscanearHoy) return false;

    try {
      _escaneosUsadosHoy =
          await _scanQuotaRepository.registrarEscaneo(_claveCuota(padre));
      _cuotaCargada = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> reiniciarCuotaDiaria() async {
    final padre = _padre;
    if (padre == null) return;

    try {
      await _scanQuotaRepository.reiniciar(_claveCuota(padre));
      _escaneosUsadosHoy = 0;
      _cuotaCargada = true;
      notifyListeners();
    } catch (_) {
      // Si el almacenamiento local falla, conservamos el contador actual.
    }
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    _errorExcepcion = null;
    notifyListeners();
  }

  /// Crea una sesión simulada en memoria sin tocar el repositorio ni get_it.
  ///
  /// Uso temporal para aislar la UI mientras se diagnostica la inyección de
  /// dependencias: garantiza `haySesion == true` para que el redirect del
  /// router permita permanecer en `/home`. No solicita ni conserva datos del
  /// menor: la cuenta es únicamente del padre o tutor.
  void _montarSesionSimulada({
    required String nombre,
    required String correo,
  }) {
    final id = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    _padre = Padre(id: id, nombre: nombre, correo: correo);
    _suscripcion = Suscripcion(id: 'sub_$id', padreId: id);
    _tareas = const <Tarea>[];
    _resumen = ResumenUso(
      nombrePadre: _padre!.nombre,
      plan: TipoPlan.gratuito,
      consultasUsadas: 0,
      consultasRestantes: null,
      totalTareas: 0,
      tareasCompletadas: 0,
      cantidadHijos: 0,
    );
    _sesionSimulada = true;
    _inicializado = true;
  }

  /// Las sesiones simuladas generan un id nuevo en cada ingreso; el correo
  /// mantiene la cuota diaria estable entre esos inicios de sesión.
  String _claveCuota(Padre padre) => _sesionSimulada ? padre.correo : padre.id;

  String _nombreDesdeCorreo(String correo) {
    final usuario = correo.trim().split('@').first;
    final limpio = usuario.replaceAll(RegExp('[._-]+'), ' ').trim();
    if (limpio.isEmpty) return 'Familia';
    final nombre = limpio[0].toUpperCase() + limpio.substring(1).toLowerCase();
    return nombre.length >= 2 ? nombre : 'Familia';
  }

  Future<void> _cargarCuotaDiaria(
    String padreId, {
    bool notificar = true,
  }) async {
    try {
      _escaneosUsadosHoy = await _scanQuotaRepository.obtenerUsadosHoy(padreId);
      _cuotaCargada = true;
    } catch (_) {
      _escaneosUsadosHoy = 0;
      _cuotaCargada = false;
    }
    if (notificar) notifyListeners();
  }

  Future<void> _refrescar(String padreId, {bool notificar = true}) async {
    _padre = await _useCases.obtenerPadre(padreId);
    _suscripcion = await _useCases.obtenerSuscripcion(padreId);
    _tareas = await _useCases.obtenerTareasPorPadre(padreId);
    _resumen = await _useCases.obtenerResumenUso(padreId);
    await _cargarCuotaDiaria(_claveCuota(_padre!), notificar: false);
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
