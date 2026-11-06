import 'suscripcion.dart';

class ResumenUso {
  const ResumenUso({
    required this.nombrePadre,
    required this.plan,
    required this.consultasUsadas,
    required this.consultasRestantes,
    required this.totalTareas,
    required this.tareasCompletadas,
    required this.cantidadHijos,
  });

  final String nombrePadre;
  final TipoPlan plan;
  final int consultasUsadas;
  final int? consultasRestantes;
  final int totalTareas;
  final int tareasCompletadas;
  final int cantidadHijos;

  factory ResumenUso.fromJson(Map<String, dynamic> json) {
    return ResumenUso(
      nombrePadre: json['nombrePadre'] as String? ?? '',
      plan: TipoPlan.fromValue(json['plan'] as String?),
      consultasUsadas: (json['consultasUsadas'] as num?)?.toInt() ?? 0,
      consultasRestantes: (json['consultasRestantes'] as num?)?.toInt(),
      totalTareas: (json['totalTareas'] as num?)?.toInt() ?? 0,
      tareasCompletadas:
          (json['tareasCompletadas'] as num?)?.toInt() ?? 0,
      cantidadHijos: (json['cantidadHijos'] as num?)?.toInt() ?? 0,
    );
  }
}
