import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso de privacidad'),
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
                    'Aviso de privacidad de EduGuía',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Última actualización: pendiente de revisión legal.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 12),
                  ),
                  SizedBox(height: 20),
                  _Seccion(
                    titulo: '1. Responsable',
                    texto:
                        'EduGuía es responsable del tratamiento de los datos '
                        'personales que proporcionas al crear una cuenta y al '
                        'usar la aplicación.',
                  ),
                  _Seccion(
                    titulo: '2. Datos que recabamos',
                    texto: 'Nombre del padre o tutor, correo electrónico, '
                        'contraseña cifrada, nombre y edad de los hijos, grado '
                        'escolar e imágenes de las tareas que decides escanear.',
                  ),
                  _Seccion(
                    titulo: '3. Finalidades',
                    texto:
                        'Usamos los datos para crear tu cuenta, analizar las '
                        'tareas, generar explicaciones y preguntas guía, '
                        'guardar tu historial local y gestionar la suscripción '
                        'Premium. No vendemos tus datos.',
                  ),
                  _Seccion(
                    titulo: '4. Imágenes de tareas',
                    texto:
                        'Las fotografías se envían al servicio de análisis para '
                        'generar el resultado. El historial guarda únicamente el '
                        'texto pedagógico y se almacena en este dispositivo.',
                  ),
                  _Seccion(
                    titulo: '5. Proveedores',
                    texto:
                        'Podemos usar servicios de inteligencia artificial para '
                        'el análisis y plataformas de compras integradas para '
                        'gestionar Premium. Estos proveedores tratan los datos '
                        'conforme a sus propias políticas.',
                  ),
                  _Seccion(
                    titulo: '6. Derechos ARCO',
                    texto:
                        'Puedes solicitar acceso, rectificación, cancelación u '
                        'oposición al tratamiento de tus datos escribiendo a '
                        'hola@eduguia.mx.',
                  ),
                  _Seccion(
                    titulo: '7. Contacto',
                    texto:
                        'Para dudas sobre este aviso escribe a hola@eduguia.mx.',
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
              'Texto de ejemplo pendiente de revisión legal. Debe validarse '
              'con un abogado antes de publicarse.',
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
