import 'package:flutter/foundation.dart';

import '../../core/errors/domain_exception.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/usecases/edu_guia_use_cases.dart';

/// Estados posibles del flujo de análisis de una tarea escaneada.
enum EstadoAnalisis {
  inactivo,
  analizando,
  completado,
  error,
}

/// Provider que gestiona el ciclo de vida del análisis de tareas escolares.
///
/// Coordina la creación de la tarea, el inicio del análisis y la obtención
/// de un resultado mock (simulado) que varía entre tres materias distintas.
class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider({required EduGuiaUseCases useCases}) : _useCases = useCases;

  final EduGuiaUseCases _useCases;

  // ──────────────────────────── Estado interno ────────────────────────────

  EstadoAnalisis _estado = EstadoAnalisis.inactivo;
  Tarea? _tareaActual;
  String? _error;
  String? _imagenPath;

  /// Contador interno para alternar entre resultados mock.
  int _contadorResultados = 0;

  // ─────────────────────────────── Getters ────────────────────────────────

  EstadoAnalisis get estado => _estado;
  Tarea? get tareaActual => _tareaActual;
  String? get error => _error;
  String? get imagenPath => _imagenPath;

  // ──────────────────────── Resultados simulados ──────────────────────────

  /// Devuelve uno de tres [ResultadoAnalisis] mock según el contador interno.
  ResultadoAnalisis _obtenerResultadoMock() {
    final indice = _contadorResultados % 3;
    _contadorResultados++;

    switch (indice) {
      case 0:
        return ResultadoAnalisis(
          materia: 'Matemáticas',
          temaDetectado: 'Fracciones equivalentes',
          metodoSep:
              'La SEP recomienda iniciar con material concreto (regletas, '
              'círculos fraccionarios) y representaciones gráficas antes de '
              'pasar a la regla numérica. Se sugiere usar la recta numérica '
              'para que el niño visualice la equivalencia.',
          preguntasGuia: const <String>[
            '¿Qué representa cada parte sombreada en el dibujo?',
            '¿Puedes usar un objeto de casa (una pizza, una naranja) para mostrar esa fracción?',
            '¿Qué pasaría si dividieras cada parte en dos partes iguales?',
          ],
        );
      case 1:
        return ResultadoAnalisis(
          materia: 'Español',
          temaDetectado: 'Comprensión lectora – Identificar idea principal',
          metodoSep:
              'El enfoque SEP promueve la lectura en voz alta seguida de '
              'preguntas abiertas. Se busca que el niño identifique de qué '
              'trata el texto con sus propias palabras antes de subrayar o '
              'copiar.',
          preguntasGuia: const <String>[
            '¿De qué crees que trata esta lectura? Cuéntamelo como si fuera un cuento corto.',
            '¿Cuál es la parte más importante del texto y por qué?',
            '¿Hay alguna palabra que no entiendas? ¿Qué crees que significa por el contexto?',
          ],
        );
      default:
        return ResultadoAnalisis(
          materia: 'Ciencias Naturales',
          temaDetectado: 'Estados de la materia',
          metodoSep:
              'La SEP sugiere partir de la observación directa y '
              'experimentos sencillos (hielo derritiéndose, agua hirviendo). '
              'El niño debe registrar lo que observa antes de recibir '
              'definiciones formales.',
          preguntasGuia: const <String>[
            '¿Qué le pasa al hielo cuando lo dejas en la mesa? ¿Por qué crees que sucede?',
            '¿Puedes nombrar tres cosas de tu casa que estén en diferente estado (sólido, líquido, gas)?',
            '¿Qué necesitarías hacer para que el agua se convierta en vapor?',
          ],
        );
    }
  }

  // ───────────────────────── Acciones públicas ────────────────────────────

  /// Ejecuta el flujo completo de análisis de una tarea:
  /// crear → iniciar análisis → simular IA → completar con resultado mock.
  Future<void> analizarTarea({
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
  }) async {
    // 1. Transición a estado «analizando».
    _estado = EstadoAnalisis.analizando;
    _error = null;
    _tareaActual = null;
    _imagenPath = imagenUrl;
    notifyListeners();

    try {
      // 2. Crear la tarea en el repositorio.
      final tarea = await _useCases.crearTarea(
        padreId: padreId,
        imagenUrl: imagenUrl,
        nombreHijo: nombreHijo,
      );

      // 3. Iniciar el análisis (cambia estado de la tarea a ANALIZANDO).
      final tareaAnalizando = await _useCases.iniciarAnalisisTarea(tarea.id);

      // 4. Simular tiempo de procesamiento de IA.
      await Future.delayed(const Duration(seconds: 2));

      // 5. Obtener resultado mock y completar el análisis.
      final resultado = _obtenerResultadoMock();
      final tareaCompletada = await _useCases.completarAnalisisTarea(
        tareaAnalizando.id,
        resultado,
      );

      // 6. Éxito: guardar la tarea completada y notificar.
      _tareaActual = tareaCompletada;
      _estado = EstadoAnalisis.completado;
      notifyListeners();
    } on DomainException catch (e) {
      _error = e.message;
      _estado = EstadoAnalisis.error;
      notifyListeners();
    } catch (_) {
      _error = 'Ocurrió un error inesperado al analizar la tarea. '
          'Intenta de nuevo.';
      _estado = EstadoAnalisis.error;
      notifyListeners();
    }
  }

  /// Reinicia el provider a su estado inicial, listo para un nuevo escaneo.
  void reiniciar() {
    _estado = EstadoAnalisis.inactivo;
    _tareaActual = null;
    _error = null;
    _imagenPath = null;
    notifyListeners();
  }

  /// Limpia únicamente el error sin cambiar el estado general.
  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
