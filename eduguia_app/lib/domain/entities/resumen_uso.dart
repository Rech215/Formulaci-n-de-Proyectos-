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
}
