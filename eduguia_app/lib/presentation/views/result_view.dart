import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/analysis_provider.dart';
import '../state/session_provider.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AnalysisProvider, SessionProvider>(
      builder: (context, analysis, session, _) {
        final tarea = analysis.tareaActual;

        if (tarea == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 52,
                    color: AppColors.brand600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay un resultado para mostrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escanea una tarea o elige una del historial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate500),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/escanear'),
                    child: const Text('Escanear tarea'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                color: AppColors.green600,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Análisis completado',
                                style: TextStyle(
                                  color: AppColors.green600,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          tarea.nombreHijo,
                          style: const TextStyle(
                            color: AppColors.slate500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.brand50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_stories,
                              color: AppColors.brand600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brand50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tarea.materia,
                                    style: const TextStyle(
                                      color: AppColors.brand700,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  tarea.temaDetectado,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slate900,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_existeImagen(tarea.imagenUrl)) ...<Widget>[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(tarea.imagenUrl),
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _Seccion(
                      icono: Icons.school_outlined,
                      titulo: 'Método SEP detectado',
                      colorIcono: AppColors.green600,
                      borde: AppColors.slate200,
                      hijo: Text(
                        tarea.metodoSep.isEmpty
                            ? 'No se detectó un método específico.'
                            : tarea.metodoSep,
                        style: const TextStyle(
                          color: AppColors.slate600,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Seccion(
                      icono: Icons.chat_bubble_outline,
                      titulo: 'Preguntas guía para tu hijo',
                      colorIcono: AppColors.brand600,
                      borde: AppColors.brand200,
                      hijo: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'No le des la respuesta: usa estas preguntas para '
                            'que descubra el camino.',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (var i = 0; i < tarea.preguntasGuia.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brand100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: AppColors.brand700,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        tarea.preguntasGuia[i],
                                        style: const TextStyle(
                                          color: AppColors.slate700,
                                          fontSize: 15,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.yellow100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.yellow600.withAlpha(51),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.shield_outlined,
                            color: AppColors.yellow600,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Regla de oro: valida su intento y devuélvele una '
                              'pregunta como "¿cómo podrías comprobarlo?". '
                              'Nunca le des el resultado final.',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!session.esPremium) ...<Widget>[
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.go('/premium'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.brand50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.brand200),
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(
                                Icons.workspace_premium_outlined,
                                color: AppColors.brand700,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Quita los anuncios y apoya el aprendizaje '
                                  'de tu hijo por \$69 al mes.',
                                  style: TextStyle(
                                    color: AppColors.brand700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.brand700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.read<AnalysisProvider>().reiniciar();
                          context.go('/escanear');
                        },
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Escanear otra tarea'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/history'),
                            icon: const Icon(Icons.history_edu_outlined),
                            label: const Text('Historial'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/home'),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('Inicio'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _existeImagen(String ruta) {
    if (ruta.trim().isEmpty) return false;
    try {
      return File(ruta).existsSync();
    } catch (_) {
      return false;
    }
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.colorIcono,
    required this.borde,
    required this.hijo,
  });

  final IconData icono;
  final String titulo;
  final Color colorIcono;
  final Color borde;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icono, color: colorIcono, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: colorIcono,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          hijo,
        ],
      ),
    );
  }
}
