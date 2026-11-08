import '../../core/errors/domain_exception.dart';

class Hijo {
  const Hijo._({
    required this.nombre,
    required this.edad,
    required this.gradoEscolar,
  });

  factory Hijo({
    required String nombre,
    required int edad,
    required String gradoEscolar,
  }) {
    final nombreLimpio = nombre.trim();
    final gradoLimpio = gradoEscolar.trim();

    if (nombreLimpio.length < 2) {
      throw const DomainException(
        'El nombre del hijo debe tener al menos 2 caracteres.',
      );
    }
    if (edad < 3 || edad > 18) {
      throw DomainException(
        'Edad inválida: $edad. Debe estar entre 3 y 18 años.',
      );
    }
    if (gradoLimpio.isEmpty) {
      throw const DomainException('El grado escolar es obligatorio.');
    }

    return Hijo._(nombre: nombreLimpio, edad: edad, gradoEscolar: gradoLimpio);
  }

  final String nombre;
  final int edad;
  final String gradoEscolar;

  Hijo copyWith({String? nombre, int? edad, String? gradoEscolar}) {
    return Hijo(
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      gradoEscolar: gradoEscolar ?? this.gradoEscolar,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'edad': edad,
        'gradoEscolar': gradoEscolar,
      };

  factory Hijo.fromJson(Map<String, dynamic> json) {
    return Hijo(
      nombre: json['nombre'] as String? ?? '',
      edad: (json['edad'] as num?)?.toInt() ?? 0,
      gradoEscolar: json['gradoEscolar'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Hijo &&
        other.nombre == nombre &&
        other.edad == edad &&
        other.gradoEscolar == gradoEscolar;
  }

  @override
  int get hashCode => Object.hash(nombre, edad, gradoEscolar);
}
