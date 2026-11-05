import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/section_header.dart';

class ProblemView extends StatelessWidget {
  const ProblemView({super.key});

  static const List<_ProblemaData> _problemas = <_ProblemaData>[
    _ProblemaData(
      icon: Icons.error_outline,
      iconColor: AppColors.red600,
      iconBackground: AppColors.red100,
      title: 'Métodos desconocidos',
      description:
          'Las escuelas de hoy enseñan matemáticas y otras materias de forma '
          'distinta a como tú aprendiste. Es fácil sentirse perdido.',
    ),
    _ProblemaData(
      icon: Icons.forum_outlined,
      iconColor: AppColors.orange600,
      iconBackground: AppColors.orange100,
      title: 'Momentos de tensión',
      description:
          'Al intentar explicar a tu manera, el niño se confunde con lo que '
          'dijo su maestro. Lo que debería ser convivencia termina en discusión.',
    ),
    _ProblemaData(
      icon: Icons.verified_user_outlined,
      iconColor: AppColors.brand600,
      iconBackground: AppColors.brand100,
      title: 'Dar la respuesta no ayuda',
      description:
          'Darles el resultado rápido alivia el estrés temporal, pero perjudica '
          'su aprendizaje a largo plazo y su confianza.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: <Widget>[
              const SectionHeader(
                eyebrow: 'El problema',
                eyebrowColor: AppColors.red500,
                title: 'La hora de la tarea no debería ser una batalla',
                subtitle:
                    'Sabemos que quieres ayudar a tu hijo, pero la educación ha cambiado.',
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  final cardWidth = isWide
                      ? (constraints.maxWidth - 32) / 3
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      for (final problema in _problemas)
                        SizedBox(
                          width: cardWidth,
                          child: _ProblemaCard(data: problema),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/como-funciona'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Ver cómo lo solucionamos',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProblemaCard extends StatelessWidget {
  const _ProblemaCard({required this.data});

  final _ProblemaData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: const TextStyle(
              color: AppColors.slate600,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemaData {
  const _ProblemaData({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
}
