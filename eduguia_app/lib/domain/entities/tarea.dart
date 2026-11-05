import '../../core/errors/domain_exception.dart';

enum EstadoTarea {
  pendiente('PENDIENTE'),
  analizando('ANALIZANDO'),
  completada('COMPLETADA'),
  error('ERROR');

  const EstadoTarea(this.value);

  final String value;

  static EstadoTarea fromValue(String? value) {
    return EstadoTarea.values.firstWhere(
      (estado) => estado.value == value,
      orElse: () => EstadoTarea.pendiente,
    );
  }
}

class ResultadoAnalisis {
  const ResultadoAnalisis._({
    required this.materia,
    required this.temaDetectado,
    required this.metodoSep,
    required this.preguntasGuia,
  });

  factory ResultadoAnalisis({
    required String materia,
    required String temaDetectado,
    required String metodoSep,
    required List<String> preguntasGuia,
  }) {
    final materiaLimpia = materia.trim();
    final temaLimpio = temaDetectado.trim();
    final metodoLimpio = metodoSep.trim();
    final preguntasLimpias = preguntasGuia
        .map((pregunta) => pregunta.trim())
        .where((pregunta) => pregunta.isNotEmpty)
        .toList(growable: false);

    if (materiaLimpia.isEmpty || temaLimpio.isEmpty) {
      throw const DomainException(
        'El resultado del análisis debe incluir materia y tema detectado.',
      );
    }
    if (preguntasLimpias.isEmpty) {
      throw const DomainException(
        'El resultado debe incluir al menos una pregunta guía.',
      );
    }

    return ResultadoAnalisis._(
      materia: materiaLimpia,
      temaDetectado: temaLimpio,
      metodoSep: metodoLimpio,
      preguntasGuia: List<String>.unmodifiable(preguntasLimpias),
    );
  }

  final String materia;
  final String temaDetectado;
  final String metodoSep;
  final List<String> preguntasGuia;

  Map<String, dynamic> toJson() => {
        'materia': materia,
        'temaDetectado': temaDetectado,
        'metodoSEP': metodoSep,
        'preguntasGuia': preguntasGuia,
      };

  factory ResultadoAnalisis.fromJson(Map<String, dynamic> json) {
    final preguntas = json['preguntasGuia'] as List<dynamic>? ?? const <dynamic>[];
    return ResultadoAnalisis(
      materia: json['materia'] as String? ?? '',
      temaDetectado: json['temaDetectado'] as String? ?? '',
      metodoSep: json['metodoSEP'] as String? ?? '',
      preguntasGuia: preguntas.map((item) => item.toString()).toList(),
    );
  }
}

class Tarea {
  const Tarea._({
    required this.id,
    required this.padreId,
    required this.imagenUrl,
    required this.estado,
    required this.materia,
    required this.temaDetectado,
    required this.metodoSep,
    required this.preguntasGuia,
    required this.fechaCreacion,
    required this.nombreHijo,
    required this.mensajeError,
  });

  factory Tarea({
    required String id,
    required String padreId,
    required String imagenUrl,
    required String nombreHijo,
    EstadoTarea estado = EstadoTarea.pendiente,
    String materia = '',
    String temaDetectado = '',
    String metodoSep = '',
    List<String> preguntasGuia = const <String>[],
    DateTime? fechaCreacion,
    String? mensajeError,
  }) {
    final idLimpio = id.trim();
    final padreIdLimpio = padreId.trim();
    final urlLimpia = imagenUrl.trim();
    final nombreHijoLimpio = nombreHijo.trim();

    if (idLimpio.isEmpty) {
      throw const DomainException('La tarea debe tener un identificador.');
    }
    if (padreIdLimpio.isEmpty) {
      throw const DomainException('La tarea debe pertenecer a un padre.');
    }
    if (urlLimpia.isEmpty) {
      throw const DomainException('La URL de la imagen no puede estar vacía.');
    }
    if (nombreHijoLimpio.isEmpty) {
      throw const DomainException('La tarea debe indicar el nombre del hijo.');
    }

    return Tarea._(
      id: idLimpio,
      padreId: padreIdLimpio,
      imagenUrl: urlLimpia,
      estado: estado,
      materia: materia.trim(),
      temaDetectado: temaDetectado.trim(),
      metodoSep: metodoSep.trim(),
      preguntasGuia: List<String>.unmodifiable(preguntasGuia),
      fechaCreacion: fechaCreacion ?? DateTime.now(),
      nombreHijo: nombreHijoLimpio,
      mensajeError: mensajeError,
    );
  }

  static const Object _sinCambio = Object();

  final String id;
  final String padreId;
  final String imagenUrl;
  final EstadoTarea estado;
  final String materia;
  final String temaDetectado;
  final String metodoSep;
  final List<String> preguntasGuia;
  final DateTime fechaCreacion;
  final String nombreHijo;
  final String? mensajeError;

  bool get esFinal =>
      estado == EstadoTarea.completada || estado == EstadoTarea.error;

  Tarea iniciarAnalisis() {
    if (estado != EstadoTarea.pendiente) {
      throw DomainException(
        'No se puede iniciar análisis: la tarea está en estado "${estado.value}".',
      );
    }
    return copyWith(estado: EstadoTarea.analizando);
  }

  Tarea completarAnalisis(ResultadoAnalisis resultado) {
    if (estado != EstadoTarea.analizando) {
      throw DomainException(
        'No se puede completar: la tarea está en estado "${estado.value}".',
      );
    }
    return copyWith(
      estado: EstadoTarea.completada,
      materia: resultado.materia,
      temaDetectado: resultado.temaDetectado,
      metodoSep: resultado.metodoSep,
      preguntasGuia: resultado.preguntasGuia,
      mensajeError: null,
    );
  }

  Tarea marcarError(String mensaje) {
    if (estado == EstadoTarea.completada) {
      throw const DomainException(
        'No se puede marcar error en una tarea ya completada.',
      );
    }
    return copyWith(
      estado: EstadoTarea.error,
      mensajeError: mensaje.trim(),
    );
  }

  Tarea copyWith({
    EstadoTarea? estado,
    String? materia,
    String? temaDetectado,
    String? metodoSep,
    List<String>? preguntasGuia,
    Object? mensajeError = _sinCambio,
  }) {
    return Tarea(
      id: id,
      padreId: padreId,
      imagenUrl: imagenUrl,
      nombreHijo: nombreHijo,
      estado: estado ?? this.estado,
      materia: materia ?? this.materia,
      temaDetectado: temaDetectado ?? this.temaDetectado,
      metodoSep: metodoSep ?? this.metodoSep,
      preguntasGuia: preguntasGuia ?? this.preguntasGuia,
      fechaCreacion: fechaCreacion,
      mensajeError: identical(mensajeError, _sinCambio)
          ? this.mensajeError
          : mensajeError as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'padreId': padreId,
        'imagenUrl': imagenUrl,
        'estado': estado.value,
        'materia': materia,
        'temaDetectado': temaDetectado,
        'metodoSEP': metodoSep,
        'preguntasGuia': preguntasGuia,
        'nombreHijo': nombreHijo,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'mensajeError': mensajeError,
      };

  factory Tarea.fromJson(Map<String, dynamic> json) {
    final preguntas = json['preguntasGuia'] as List<dynamic>? ?? const <dynamic>[];
    return Tarea(
      id: json['id'] as String? ?? '',
      padreId: json['padreId'] as String? ?? '',
      imagenUrl: json['imagenUrl'] as String? ?? '',
      nombreHijo: json['nombreHijo'] as String? ?? '',
      estado: EstadoTarea.fromValue(json['estado'] as String?),
      materia: json['materia'] as String? ?? '',
      temaDetectado: json['temaDetectado'] as String? ?? '',
      metodoSep: json['metodoSEP'] as String? ?? '',
      preguntasGuia: preguntas.map((item) => item.toString()).toList(),
      fechaCreacion: DateTime.tryParse(json['fechaCreacion'] as String? ?? ''),
      mensajeError: json['mensajeError'] as String?,
    );
  }
}
