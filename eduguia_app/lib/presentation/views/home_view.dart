import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/session_provider.dart';
import '../widgets/plan_badge.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _HeroSection(),
          _SessionCard(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppColors.brand50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child: _HeroCopy()),
                    SizedBox(width: 40),
                    Expanded(child: _HeroVisual()),
                  ],
                );
              }
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _HeroCopy(),
                  SizedBox(height: 32),
                  _HeroVisual(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final tituloSize = MediaQuery.sizeOf(context).width >= 760 ? 46.0 : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.brand500,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 8, height: 8),
                ),
                SizedBox(width: 8),
                Text(
                  'La primera IA para padres',
                  style: TextStyle(
                    color: AppColors.brand700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Acompaña su aprendizaje sin hacerle la tarea.',
          style: TextStyle(
            color: AppColors.slate900,
            fontSize: tituloSize,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Entiende cómo le enseñan hoy en la escuela. Nuestra IA te explica '
          'el método y te da las preguntas correctas para que tu hijo descubra '
          'la respuesta por sí mismo.',
          style: TextStyle(
            color: AppColors.slate600,
            fontSize: 17,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => context.go('/planes'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Comienza tu prueba gratis',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.go('/como-funciona'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate700,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.slate200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Ver cómo funciona',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: <Widget>[
            Icon(Icons.check_circle, size: 17, color: AppColors.green500),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'No requiere tarjeta de crédito para iniciar',
                style: TextStyle(color: AppColors.slate500, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.12,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.brand700, AppColors.brand500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.brand900.withAlpha(46),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(31),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 62,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Aprender juntos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guía, no respuestas',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: _FloatingInsight(),
          ),
        ],
      ),
    );
  }
}

class _FloatingInsight extends StatelessWidget {
  const _FloatingInsight();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.slate900.withAlpha(31),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.yellow100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              color: AppColors.yellow600,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '¡Lo entendió!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                'Fracciones dominadas',
                style: TextStyle(fontSize: 11, color: AppColors.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        if (!session.haySesion) {
          if (session.cargando) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brand600),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final padre = session.padre!;
        final suscripcion = session.suscripcion;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppColors.slate200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.insights_outlined,
                            color: AppColors.brand600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tu sesión demo',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (suscripcion != null)
                            PlanBadge(premium: suscripcion.esPremium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        padre.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hijos: ${padre.hijos.map((hijo) => hijo.nombre).join(', ')}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate500,
                        ),
                      ),
                      if (suscripcion != null) ...<Widget>[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: <Widget>[
                            _Metric(
                              label: 'Consultas usadas',
                              value: '${suscripcion.consultasUsadas}',
                            ),
                            _Metric(
                              label: 'Restantes',
                              value: suscripcion.esIlimitada
                                  ? '∞'
                                  : '${suscripcion.consultasRestantes}',
                            ),
                            _Metric(
                              label: 'Tareas',
                              value: '${session.tareas.length}',
                            ),
                          ],
                        ),
                      ],
                      if (session.error != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          session.error!,
                          style: const TextStyle(
                            color: AppColors.red600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: session.cargando
                                ? null
                                : () => context.go('/escanear'),
                            icon: const Icon(
                              Icons.photo_camera_outlined,
                              size: 18,
                            ),
                            label: const Text('Escanear tarea'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brand600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/planes'),
                            icon: const Icon(
                              Icons.workspace_premium_outlined,
                              size: 18,
                            ),
                            label: const Text('Mejorar plan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brand700,
                              side: const BorderSide(color: AppColors.brand200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: session.cargando
                                ? null
                                : () => _simular(context),
                            icon: const Icon(
                              Icons.science_outlined,
                              size: 18,
                            ),
                            label: const Text('Probar escaneo'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _simular(BuildContext context) async {
    context.go('/escanear');
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.slate900,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.slate500),
        ),
      ],
    );
  }
}
