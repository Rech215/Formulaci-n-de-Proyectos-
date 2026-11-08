import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _AvisoPlaceholder(),
                  SizedBox(height: 18),
                  Text(
                    'Contacto y soporte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Canales de atención para padres, tutores y escuelas.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 13),
                  ),
                  SizedBox(height: 20),
                  _Canal(
                    icono: Icons.mail_outline,
                    titulo: 'Correo de soporte',
                    valor: 'soporte@eduguia.mx',
                    descripcion:
                        'Escríbenos con el correo de tu cuenta y describe el '
                        'problema o la duda.',
                  ),
                  SizedBox(height: 12),
                  _Canal(
                    icono: Icons.schedule_outlined,
                    titulo: 'Horario de atención',
                    valor: 'Lunes a viernes, 9:00 a 18:00 (CDMX)',
                    descripcion:
                        'Respondemos en un plazo máximo de 48 horas hábiles.',
                  ),
                  SizedBox(height: 12),
                  _Canal(
                    icono: Icons.business_outlined,
                    titulo: 'Datos del responsable',
                    valor: 'Pendiente de completar',
                    descripcion:
                        'Razón social, domicilio fiscal y teléfono de contacto '
                        'para avisos legales.',
                  ),
                  SizedBox(height: 22),
                  _Seccion(
                    titulo: 'Soporte técnico',
                    texto: 'Incluye el modelo de tu dispositivo, la versión de '
                        'Android o iOS y una captura de pantalla si es posible. '
                        'Así podremos reproducir el problema con mayor rapidez.',
                  ),
                  _Seccion(
                    titulo: 'Privacidad y datos personales',
                    texto: 'Para ejercer tus derechos ARCO o solicitar la '
                        'eliminación de tu cuenta escribe a privacidad@eduguia.mx '
                        'desde el correo registrado.',
                  ),
                  _Seccion(
                    titulo: 'Suscripciones y pagos',
                    texto:
                        'Las compras y reembolsos de Premium se gestionan desde '
                        'Google Play o App Store. Si necesitas ayuda con tu '
                        'suscripción, comparte el número de comprobante.',
                  ),
                  _Seccion(
                    titulo: 'Tiempo de respuesta',
                    texto:
                        'Consultas generales: hasta 48 horas hábiles. Incidentes '
                        'de seguridad o privacidad: revisión prioritaria dentro '
                        'de 24 horas hábiles.',
                  ),
                  _Seccion(
                    titulo: 'Aviso legal',
                    texto:
                        'Este contenido es un contenedor de ejemplo pendiente de '
                        'revisión legal. Sustituye correos, plazos, razón social '
                        'y domicilio por la información oficial de EduGuía.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoPlaceholder extends StatelessWidget {
  const _AvisoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.yellow100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.yellow600.withAlpha(64)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, color: AppColors.yellow600, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Información de contacto de ejemplo. Debe completarse y validarse '
              'antes de publicar la aplicación.',
              style: TextStyle(
                color: AppColors.slate700,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Canal extends StatelessWidget {
  const _Canal({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.descripcion,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.brand50,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppColors.brand600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.brand700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.slate600,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
