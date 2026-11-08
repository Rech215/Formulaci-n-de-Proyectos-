import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/suscripcion.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de servicio'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.yellow100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.yellow600.withAlpha(64),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          color: AppColors.yellow600,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Texto de ejemplo pendiente de revisión legal. '
                            'Debe validarse con un abogado antes de publicarse.',
                            style: TextStyle(
                              color: AppColors.slate700,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Términos de servicio de EduGuía',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Última actualización: pendiente de revisión legal.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  const _Seccion(
                    titulo: '1. Uso de la aplicación',
                    texto: 'EduGuía es una herramienta de apoyo para padres y '
                        'tutores. No sustituye la enseñanza escolar ni la '
                        'evaluación de un docente. El usuario se compromete a '
                        'usarla de forma responsable.',
                  ),
                  const _Seccion(
                    titulo: '2. Cuentas',
                    texto: 'Debes proporcionar información veraz y mantener la '
                        'confidencialidad de tu contraseña. Eres responsable de '
                        'la actividad realizada desde tu cuenta.',
                  ),
                  const _Seccion(
                    titulo: '3. Contenido de las tareas',
                    texto:
                        'Al escanear una tarea declaras que tienes derecho a '
                        'compartir la imagen. No debes subir contenido ilegal, '
                        'ofensivo o que vulnere derechos de terceros.',
                  ),
                  const _Seccion(
                    titulo: '4. Plan Gratis y Premium',
                    texto: 'El plan Gratis permite escaneos ilimitados con un '
                        'anuncio después de cada escaneo. Premium cuesta '
                        '\$${Suscripcion.precioPremiumMxn} MXN al mes y elimina '
                        'los anuncios. El cobro se gestiona mediante la tienda '
                        'de tu dispositivo.',
                  ),
                  const _Seccion(
                    titulo: '5. Cancelación y reembolsos',
                    texto:
                        'Puedes cancelar tu suscripción desde la tienda donde '
                        'la contrataste. Los reembolsos se rigen por la política '
                        'de la tienda correspondiente.',
                  ),
                  const _Seccion(
                    titulo: '6. Limitación de responsabilidad',
                    texto:
                        'La aplicación ofrece orientación educativa generada con '
                        'apoyo de inteligencia artificial. No garantizamos '
                        'resultados académicos específicos ni la exactitud total '
                        'del contenido.',
                  ),
                  const _Seccion(
                    titulo: '7. Contacto',
                    texto: 'Para dudas sobre estos términos escribe a '
                        'hola@eduguia.mx.',
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

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
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
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
