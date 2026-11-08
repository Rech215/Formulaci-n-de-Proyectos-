import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/tarea.dart';
import '../state/analysis_provider.dart';
import '../state/session_provider.dart';
import '../widgets/plan_badge.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        final padre = session.padre;
        final tareas = session.tareas.take(3).toList(growable: false);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _saludo(),
                                style: const TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                padre?.nombre ?? 'Familia',
                                style: const TextStyle(
                                  color: AppColors.slate900,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PlanBadge(premium: session.esPremium),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _TarjetaEscanear(
                      hijo: padre != null && padre.hijos.isNotEmpty
                          ? padre.hijos.first.nombre
                          : null,
                      premium: session.esPremium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _AccesoRapido(
                            icono: Icons.history_edu_outlined,
                            titulo: 'Historial',
                            subtitulo: 'Repasa tareas',
                            onTap: () => context.go('/history'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AccesoRapido(
                            icono: session.esPremium
                                ? Icons.verified_outlined
                                : Icons.workspace_premium_outlined,
                            titulo:
                                session.esPremium ? 'Premium' : 'Sin anuncios',
                            subtitulo: session.esPremium
                                ? 'Plan activo'
                                : 'Desde \$69 al mes',
                            onTap: () => context.go('/premium'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Tus últimas tareas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        if (tareas.isNotEmpty)
                          TextButton(
                            onPressed: () => context.go('/history'),
                            child: const Text('Ver todo'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (tareas.isEmpty)
                      const _ConsejoInicial()
                    else
                      for (final tarea in tareas) _TareaReciente(tarea: tarea),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

class _TarjetaEscanear extends StatelessWidget {
  const _TarjetaEscanear({required this.hijo, required this.premium});

  final String? hijo;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => context.go('/escanear'),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppColors.brand700, AppColors.brand500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.brand900.withAlpha(38),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(36),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(36),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      premium ? 'Sin anuncios' : 'Gratis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Escanea una tarea',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hijo == null
                    ? 'Toma una foto y recibe el método SEP y preguntas guía '
                        'para acompañar a tu hijo.'
                    : 'Toma una foto de la tarea de $hijo y recibe el método '
                        'SEP y preguntas guía para acompañarlo.',
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.photo_camera_outlined,
                            color: AppColors.brand700,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Abrir cámara',
                            style: TextStyle(
                              color: AppColors.brand700,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  const _AccesoRapido({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icono, color: AppColors.brand600, size: 22),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: const TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TareaReciente extends StatelessWidget {
  const _TareaReciente({required this.tarea});

  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.read<AnalysisProvider>().mostrarTarea(tarea);
            context.go('/result');
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.brand50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.brand600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tarea.materia.isEmpty
                            ? 'Tarea analizada'
                            : tarea.materia,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tarea.nombreHijo} · ${_fecha(tarea.fechaCreacion)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.slate400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fecha(DateTime fecha) {
    const meses = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}';
  }
}

class _ConsejoInicial extends StatelessWidget {
  const _ConsejoInicial();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brand200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.tips_and_updates_outlined, color: AppColors.brand600),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aún no hay tareas. Busca buena luz, captura toda la '
              'instrucción y evita sombras para un mejor análisis.',
              style: TextStyle(
                color: AppColors.slate600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
