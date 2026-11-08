import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

enum EstadoAnalisis { inactivo, analizando, completado, error }

class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider({
    required EduGuiaUseCases useCases,
    Duration latenciaSimulada = Duration.zero,
  })  : _useCases = useCases,
        _latenciaSimulada = latenciaSimulada;

  final EduGuiaUseCases _useCases;
  final Duration _latenciaSimulada;

  EstadoAnalisis _estado = EstadoAnalisis.inactivo;
  Tarea? _tareaActual;
  String? _error;
  DomainException? _errorExcepcion;
  String? _imagenPath;

  EstadoAnalisis get estado => _estado;
  Tarea? get tareaActual => _tareaActual;
  String? get error => _error;
  DomainException? get errorExcepcion => _errorExcepcion;
  String? get imagenPath => _imagenPath;

  Future<void> analizarTarea({
    required String padreId,
    required String imagenPath,
    required String nombreHijo,
    String materiaSugerida = '',
  }) async {
    _estado = EstadoAnalisis.analizando;
    _error = null;
    _errorExcepcion = null;
    _tareaActual = null;
    _imagenPath = imagenPath;
    notifyListeners();

    try {
      if (_latenciaSimulada > Duration.zero) {
        await Future<void>.delayed(_latenciaSimulada);
      }

      final tarea = await _useCases.analizarTarea(
        padreId: padreId,
        imagenPath: imagenPath,
        nombreHijo: nombreHijo,
        materiaSugerida: materiaSugerida,
      );

      _tareaActual = tarea;
      _estado = EstadoAnalisis.completado;
      notifyListeners();
    } on DomainException catch (error) {
      _errorExcepcion = error;
      _error = error.message;
      _estado = EstadoAnalisis.error;
      notifyListeners();
    } catch (_) {
      const error = DomainException(
        'Ocurrió un error inesperado al analizar la tarea. Intenta de nuevo.',
      );
      _errorExcepcion = error;
      _error = error.message;
      _estado = EstadoAnalisis.error;
      notifyListeners();
    }
  }

  void mostrarTarea(Tarea tarea) {
    _tareaActual = tarea;
    _imagenPath = tarea.imagenUrl;
    _error = null;
    _errorExcepcion = null;
    _estado = tarea.estado == EstadoTarea.completada
        ? EstadoAnalisis.completado
        : EstadoAnalisis.inactivo;
    notifyListeners();
  }

  void reiniciar() {
    _estado = EstadoAnalisis.inactivo;
    _tareaActual = null;
    _error = null;
    _errorExcepcion = null;
    _imagenPath = null;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    _errorExcepcion = null;
    notifyListeners();
  }
}
