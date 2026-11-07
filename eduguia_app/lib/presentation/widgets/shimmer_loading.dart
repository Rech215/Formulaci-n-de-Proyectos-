import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Aplica un barrido de brillo sobre cualquier widget opaco.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final desplazamiento = _controller.value * 2;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 - desplazamiento, 0),
              end: Alignment(1 - desplazamiento, 0),
              colors: const <Color>[
                AppColors.slate200,
                AppColors.slate50,
                AppColors.slate200,
              ],
              stops: const <double>[0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Esqueleto de carga que simula las tarjetas de método SEP y preguntas guía.
class AnalysisLoadingSkeleton extends StatelessWidget {
  const AnalysisLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: Column(
        children: <Widget>[
          _SkeletonAnalysisCard(
            icono: Icons.school_outlined,
            titulo: 'Método SEP',
            lineas: <double>[1, 0.94, 0.8],
          ),
          SizedBox(height: 14),
          _SkeletonAnalysisCard(
            icono: Icons.chat_bubble_outline,
            titulo: 'Preguntas guía',
            lineas: <double>[0.9, 1, 0.86, 0.72],
            numerada: true,
          ),
        ],
      ),
    );
  }
}

class _SkeletonAnalysisCard extends StatelessWidget {
  const _SkeletonAnalysisCard({
    required this.icono,
    required this.titulo,
    required this.lineas,
    this.numerada = false,
  });

  final IconData icono;
  final String titulo;
  final List<double> lineas;
  final bool numerada;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icono, color: AppColors.slate300, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final factor in lineas)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (numerada) ...<Widget>[
                    const ShimmerBox(width: 28, height: 28, radius: 14),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: factor,
                      child: const ShimmerBox(height: 12),
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

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.slate300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
