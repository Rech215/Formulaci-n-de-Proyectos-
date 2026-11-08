import '../../core/errors/domain_exception.dart';

class Plan {
  const Plan._({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioMensual,
    required this.limiteConsultas,
    required this.beneficios,
    required this.destacado,
    required this.etiqueta,
  });

  factory Plan({
    required String id,
    required String nombre,
    required String descripcion,
    required int precioMensual,
    required int? limiteConsultas,
    required List<String> beneficios,
    bool destacado = false,
    String? etiqueta,
  }) {
    final idLimpio = id.trim();
    final nombreLimpio = nombre.trim();
    final descripcionLimpia = descripcion.trim();
    final etiquetaLimpia = etiqueta?.trim();

    if (idLimpio.isEmpty) {
      throw const DomainException('El plan debe tener un identificador.');
    }
    if (nombreLimpio.isEmpty) {
      throw const DomainException('El plan debe tener un nombre.');
    }
    if (precioMensual < 0) {
      throw const DomainException('El precio mensual no puede ser negativo.');
    }

    final limiteNormalizado =
        limiteConsultas == null || limiteConsultas < 0 ? null : limiteConsultas;
    if (limiteNormalizado == 0) {
      throw const DomainException(
        'El plan debe permitir al menos una consulta.',
      );
    }

    return Plan._(
      id: idLimpio,
      nombre: nombreLimpio,
      descripcion: descripcionLimpia,
      precioMensual: precioMensual,
      limiteConsultas: limiteNormalizado,
      beneficios: List<String>.unmodifiable(beneficios),
      destacado: destacado,
      etiqueta: etiquetaLimpia == null || etiquetaLimpia.isEmpty
          ? null
          : etiquetaLimpia,
    );
  }

  final String id;
  final String nombre;
  final String descripcion;
  final int precioMensual;
  final int? limiteConsultas;
  final List<String> beneficios;
  final bool destacado;
  final String? etiqueta;

  bool get esGratuito => precioMensual == 0;

  bool get esIlimitado => limiteConsultas == null;

  String get precioFormateado => esGratuito ? '\$0' : '\$$precioMensual';

  String get limiteTexto => esIlimitado
      ? 'Consultas ilimitadas'
      : '$limiteConsultas consultas al mes';

  static Plan gratuito() {
    return Plan(
      id: 'gratuito',
      nombre: 'Gratis',
      descripcion: 'Escanea tus tareas sin costo, con anuncios.',
      precioMensual: 0,
      limiteConsultas: null,
      beneficios: const <String>[
        'Escaneos ilimitados',
        'Explicación del método escolar (SEP)',
        'Preguntas guía básicas',
        'Con anuncios entre escaneos',
      ],
    );
  }

  static Plan premium() {
    return Plan(
      id: 'premium',
      nombre: 'Premium',
      descripcion: 'Acompañamiento sin anuncios para tu hijo.',
      precioMensual: 69,
      limiteConsultas: null,
      beneficios: const <String>[
        'Escaneos ilimitados',
        'Sin anuncios',
        'Preguntas guía adaptadas a su edad',
        'Alineación curricular SEP',
        'Resumen semanal de logros y áreas de mejora',
        'Ideas de juegos para la vida diaria',
      ],
      destacado: true,
      etiqueta: 'Recomendado',
    );
  }

  static List<Plan> catalogo() => <Plan>[gratuito(), premium()];
}
