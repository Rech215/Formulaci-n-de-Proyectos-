import 'dart:math' as math;

import '../../core/errors/domain_exception.dart';

enum TipoPlan {
  gratuito('GRATUITO'),
  premium('PREMIUM');

  const TipoPlan(this.value);

  final String value;

  static TipoPlan fromValue(String? value) {
    return TipoPlan.values.firstWhere(
      (plan) => plan.value == value,
      orElse: () => TipoPlan.gratuito,
    );
  }
}

enum EstadoSuscripcion {
  activa('ACTIVA'),
  cancelada('CANCELADA'),
  expirada('EXPIRADA');

  const EstadoSuscripcion(this.value);

  final String value;

  static EstadoSuscripcion fromValue(String? value) {
    return EstadoSuscripcion.values.firstWhere(
      (estado) => estado.value == value,
      orElse: () => EstadoSuscripcion.activa,
    );
  }
}

class Suscripcion {
  const Suscripcion._({
    required this.id,
    required this.padreId,
    required this.tipoPlan,
    required this.estado,
    required this.consultasUsadas,
    required this.limiteConsultas,
    required this.fechaInicio,
    required this.fechaRenovacion,
  });

  factory Suscripcion({
    required String id,
    required String padreId,
    TipoPlan tipoPlan = TipoPlan.gratuito,
    EstadoSuscripcion estado = EstadoSuscripcion.activa,
    int consultasUsadas = 0,
    int? limiteConsultas,
    DateTime? fechaInicio,
    DateTime? fechaRenovacion,
  }) {
    final idLimpio = id.trim();
    final padreIdLimpio = padreId.trim();

    if (idLimpio.isEmpty) {
      throw const DomainException(
        'La suscripción debe tener un identificador.',
      );
    }
    if (padreIdLimpio.isEmpty) {
      throw const DomainException('La suscripción debe pertenecer a un padre.');
    }
    if (consultasUsadas < 0) {
      throw const DomainException(
        'Las consultas usadas no pueden ser negativas.',
      );
    }

    final inicio = fechaInicio ?? DateTime.now();

    return Suscripcion._(
      id: idLimpio,
      padreId: padreIdLimpio,
      tipoPlan: tipoPlan,
      estado: estado,
      consultasUsadas: consultasUsadas,
      limiteConsultas: null,
      fechaInicio: inicio,
      fechaRenovacion: fechaRenovacion ?? _calcularRenovacion(tipoPlan, inicio),
    );
  }

  static const int precioPremiumMxn = 69;
  static const Object _sinCambio = Object();

  final String id;
  final String padreId;
  final TipoPlan tipoPlan;
  final EstadoSuscripcion estado;
  final int consultasUsadas;
  final int? limiteConsultas;
  final DateTime fechaInicio;
  final DateTime? fechaRenovacion;

  bool get esPremium => tipoPlan == TipoPlan.premium;

  bool get esIlimitada => limiteConsultas == null;

  int get precioMensual => esPremium ? precioPremiumMxn : 0;

  int? get consultasRestantes {
    final limite = limiteConsultas;
    if (limite == null) return null;
    return math.max(0, limite - consultasUsadas);
  }

  bool puedeConsultar() {
    if (estado != EstadoSuscripcion.activa) return false;
    final limite = limiteConsultas;
    return limite == null || consultasUsadas < limite;
  }

  Suscripcion registrarConsulta() {
    if (estado != EstadoSuscripcion.activa) {
      throw const DomainException('La suscripción no está activa.');
    }
    return copyWith(consultasUsadas: consultasUsadas + 1);
  }

  Suscripcion actualizarPlan(TipoPlan nuevoPlan) {
    if (nuevoPlan == tipoPlan) {
      throw DomainException('Ya cuentas con el plan ${nuevoPlan.value}.');
    }
    return copyWith(
      tipoPlan: nuevoPlan,
      limiteConsultas: null,
      estado: EstadoSuscripcion.activa,
      fechaRenovacion: _calcularRenovacion(nuevoPlan, DateTime.now()),
    );
  }

  Suscripcion cancelar() {
    if (estado == EstadoSuscripcion.cancelada) {
      throw const DomainException('La suscripción ya está cancelada.');
    }
    return copyWith(estado: EstadoSuscripcion.cancelada);
  }

  Suscripcion reiniciarCiclo() {
    return copyWith(
      consultasUsadas: 0,
      fechaRenovacion: estado == EstadoSuscripcion.activa
          ? _calcularRenovacion(tipoPlan, DateTime.now())
          : fechaRenovacion,
    );
  }

  Suscripcion reactivar() {
    if (estado == EstadoSuscripcion.activa) {
      throw const DomainException('La suscripción ya está activa.');
    }
    return copyWith(
      estado: EstadoSuscripcion.activa,
      fechaRenovacion: _calcularRenovacion(tipoPlan, DateTime.now()),
    );
  }

  Suscripcion copyWith({
    TipoPlan? tipoPlan,
    EstadoSuscripcion? estado,
    int? consultasUsadas,
    Object? limiteConsultas = _sinCambio,
    Object? fechaRenovacion = _sinCambio,
  }) {
    return Suscripcion(
      id: id,
      padreId: padreId,
      tipoPlan: tipoPlan ?? this.tipoPlan,
      estado: estado ?? this.estado,
      consultasUsadas: consultasUsadas ?? this.consultasUsadas,
      limiteConsultas: identical(limiteConsultas, _sinCambio)
          ? this.limiteConsultas
          : limiteConsultas as int?,
      fechaInicio: fechaInicio,
      fechaRenovacion: identical(fechaRenovacion, _sinCambio)
          ? this.fechaRenovacion
          : fechaRenovacion as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'padreId': padreId,
        'tipoPlan': tipoPlan.value,
        'estado': estado.value,
        'consultasUsadas': consultasUsadas,
        'limiteConsultas': limiteConsultas ?? -1,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaRenovacion': fechaRenovacion?.toIso8601String(),
      };

  factory Suscripcion.fromJson(Map<String, dynamic> json) {
    final limiteRaw = (json['limiteConsultas'] as num?)?.toInt();
    final fechaRenovacionRaw = json['fechaRenovacion'] as String?;
    return Suscripcion(
      id: json['id'] as String? ?? '',
      padreId: json['padreId'] as String? ?? '',
      tipoPlan: TipoPlan.fromValue(json['tipoPlan'] as String?),
      estado: EstadoSuscripcion.fromValue(json['estado'] as String?),
      consultasUsadas: (json['consultasUsadas'] as num?)?.toInt() ?? 0,
      limiteConsultas: limiteRaw == null || limiteRaw == -1 ? null : limiteRaw,
      fechaInicio: DateTime.tryParse(json['fechaInicio'] as String? ?? ''),
      fechaRenovacion: fechaRenovacionRaw == null
          ? null
          : DateTime.tryParse(fechaRenovacionRaw),
    );
  }

  static DateTime? _calcularRenovacion(TipoPlan plan, DateTime desde) {
    if (plan == TipoPlan.gratuito) return null;
    return DateTime(desde.year, desde.month + 1, desde.day);
  }
}
