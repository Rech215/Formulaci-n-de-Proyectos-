import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

enum EstadoAnalisis {
  inactivo,
  analizando,
  completado,
  error,
}

class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider({required EduGuiaUseCases useCases}) : _useCases = useCases;

  final EduGuiaUseCases _useCases;

  EstadoAnalisis _estado = EstadoAnalisis.inactivo;
  Tarea? _tareaActual;
  String? _error;
  String? _imagenPath;

  EstadoAnalisis get estado => _estado;
  Tarea? get tareaActual => _tareaActual;
  String? get error => _error;
  String? get imagenPath => _imagenPath;

  Future<void> analizarTarea({
    required String padreId,
    required String imagenPath,
    required String nombreHijo,
    String materiaSugerida = '',
  }) async {
    _estado = EstadoAnalisis.analizando;
    _error = null;
    _tareaActual = null;
    _imagenPath = imagenPath;
    notifyListeners();

    try {
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
      _error = error.message;
      _estado = EstadoAnalisis.error;
      notifyListeners();
    } catch (_) {
      _error = 'Ocurrió un error inesperado al analizar la tarea. '
          'Intenta de nuevo.';
      _estado = EstadoAnalisis.error;
      notifyListeners();
    }
  }

  void reiniciar() {
    _estado = EstadoAnalisis.inactivo;
    _tareaActual = null;
    _error = null;
    _imagenPath = null;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
