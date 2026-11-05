import '../../core/errors/domain_exception.dart';
import 'hijo.dart';
import 'suscripcion.dart';

class Padre {
  const Padre._({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.hijos,
    required this.planActual,
    required this.fechaRegistro,
  });

  factory Padre({
    required String id,
    required String nombre,
    required String correo,
    List<Hijo> hijos = const <Hijo>[],
    TipoPlan planActual = TipoPlan.gratuito,
    DateTime? fechaRegistro,
  }) {
    final idLimpio = id.trim();
    final nombreLimpio = nombre.trim();
    final correoLimpio = correo.trim().toLowerCase();

    if (idLimpio.isEmpty) {
      throw const DomainException('El padre debe tener un identificador.');
    }
    if (nombreLimpio.length < 2) {
      throw const DomainException(
        'El nombre debe tener al menos 2 caracteres.',
      );
    }
    if (!_regexCorreo.hasMatch(correoLimpio)) {
      throw DomainException('Correo electrónico inválido: "$correo".');
    }

    final nombresRegistrados = <String>{};
    for (final hijo in hijos) {
      if (!nombresRegistrados.add(hijo.nombre.toLowerCase())) {
        throw DomainException(
          'Ya existe un hijo registrado con el nombre "${hijo.nombre}".',
        );
      }
    }

    return Padre._(
      id: idLimpio,
      nombre: nombreLimpio,
      correo: correoLimpio,
      hijos: List<Hijo>.unmodifiable(hijos),
      planActual: planActual,
      fechaRegistro: fechaRegistro ?? DateTime.now(),
    );
  }

  static final RegExp _regexCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final String id;
  final String nombre;
  final String correo;
  final List<Hijo> hijos;
  final TipoPlan planActual;
  final DateTime fechaRegistro;

  Padre copyWith({
    String? nombre,
    String? correo,
    List<Hijo>? hijos,
    TipoPlan? planActual,
    DateTime? fechaRegistro,
  }) {
    return Padre(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      hijos: hijos ?? this.hijos,
      planActual: planActual ?? this.planActual,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  Padre agregarHijo(Hijo hijo) {
    final existe = hijos.any(
      (item) => item.nombre.toLowerCase() == hijo.nombre.toLowerCase(),
    );
    if (existe) {
      throw DomainException(
        'Ya existe un hijo registrado con el nombre "${hijo.nombre}".',
      );
    }
    return copyWith(
      hijos: List<Hijo>.unmodifiable(<Hijo>[...hijos, hijo]),
    );
  }

  Padre eliminarHijo(String nombreHijo) {
    final normalizado = nombreHijo.trim().toLowerCase();
    final restantes = hijos
        .where((hijo) => hijo.nombre.toLowerCase() != normalizado)
        .toList(growable: false);

    if (restantes.length == hijos.length) {
      throw DomainException(
        'No se encontró un hijo con el nombre "$nombreHijo".',
      );
    }

    return copyWith(hijos: List<Hijo>.unmodifiable(restantes));
  }

  Hijo? obtenerHijoPorNombre(String nombre) {
    final normalizado = nombre.trim().toLowerCase();
    for (final hijo in hijos) {
      if (hijo.nombre.toLowerCase() == normalizado) {
        return hijo;
      }
    }
    return null;
  }

  Padre actualizarPlan(TipoPlan nuevoPlan) {
    return copyWith(planActual: nuevoPlan);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'hijos': hijos.map((hijo) => hijo.toJson()).toList(growable: false),
        'planActual': planActual.value,
        'fechaRegistro': fechaRegistro.toIso8601String(),
      };

  factory Padre.fromJson(Map<String, dynamic> json) {
    final hijosJson = json['hijos'] as List<dynamic>? ?? const <dynamic>[];
    return Padre(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      hijos: hijosJson
          .map(
            (item) => Hijo.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      planActual: TipoPlan.fromValue(json['planActual'] as String?),
      fechaRegistro: DateTime.tryParse(json['fechaRegistro'] as String? ?? ''),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Padre &&
        other.id == id &&
        other.nombre == nombre &&
        other.correo == correo &&
        other.planActual == planActual &&
        other.fechaRegistro == fechaRegistro &&
        _listasIguales(other.hijos, hijos);
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        correo,
        planActual,
        fechaRegistro,
        Object.hashAll(hijos),
      );

  static bool _listasIguales(List<Hijo> a, List<Hijo> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
