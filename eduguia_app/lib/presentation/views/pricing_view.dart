import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/suscripcion.dart';
import '../state/session_provider.dart';
import '../widgets/error_feedback.dart';
import '../widgets/section_header.dart';

class PricingView extends StatefulWidget {
  const PricingView({super.key});

  @override
  State<PricingView> createState() => _PricingViewState();
}

class _PricingViewState extends State<PricingView> {
  late final List<Plan> _planes;
  late String _planSeleccionado;

  @override
  void initState() {
    super.initState();
    _planes = Plan.catalogo();
    final suscripcion = context.read<SessionProvider>().suscripcion;
    _planSeleccionado =
        suscripcion?.tipoPlan == TipoPlan.premium ? 'premium' : 'gratuito';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: <Widget>[
              const SectionHeader(
                eyebrow: 'Planes',
                title: 'Invierte en su educación, mejora su relación',
                subtitle:
                    'Elige el plan que mejor se adapte a las necesidades de tu familia.',
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final cardWidth = isWide
                      ? (constraints.maxWidth - 20) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      for (final plan in _planes)
                        SizedBox(
                          width: cardWidth,
                          child: _PlanCard(
                            plan: plan,
                            seleccionado: plan.id == _planSeleccionado,
                            onTap: () => _seleccionarPlan(plan),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              const _VentajaCompetitiva(),
              const SizedBox(height: 28),
              TextButton.icon(
                onPressed: _restaurarCompras,
                icon: const Icon(Icons.restore),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand600,
                ),
                label: const Text('Restaurar compras'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/inicio'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate500,
                ),
                child: const Text('← Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restaurarCompras() async {
    final session = context.read<SessionProvider>();
    await session.restaurarCompras();
    if (!mounted) return;

    final error = session.error;
    if (error != null) {
      ErrorFeedback.show(context, session.errorExcepcion);
      session.limpiarError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          session.suscripcion?.esPremium == true
              ? 'Compras restauradas. Tu plan Premium está activo.'
              : 'No encontramos una suscripción Premium activa.',
        ),
      ),
    );
  }

  Future<void> _seleccionarPlan(Plan plan) async {
    final session = context.read<SessionProvider>();
    final tipo =
        plan.id == 'premium' ? TipoPlan.premium : TipoPlan.gratuito;

    setState(() => _planSeleccionado = plan.id);

    if (session.haySesion && session.suscripcion?.tipoPlan != tipo) {
      if (tipo == TipoPlan.premium) {
        await session.comprarPremium();
      } else {
        await session.cancelarSuscripcion();
      }

      if (!mounted) return;

      final error = session.error;
      if (error != null) {
        ErrorFeedback.show(context, session.errorExcepcion);
        session.limpiarError();
        return;
      }

      if (tipo == TipoPlan.premium &&
          session.suscripcion?.tipoPlan != TipoPlan.premium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La compra no se completó. Puedes intentarlo de nuevo.'),
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _ConfirmacionPlanDialog(plan: plan),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.seleccionado,
    required this.onTap,
  });

  final Plan plan;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premium = plan.destacado;
    final background = premium ? AppColors.brand900 : Colors.white;
    final titleColor = premium ? Colors.white : AppColors.slate900;
    final descriptionColor =
        premium ? AppColors.brand200 : AppColors.slate500;
    final priceColor = premium ? Colors.white : AppColors.slate900;
    final periodColor = premium ? AppColors.brand300 : AppColors.slate500;
    final borderColor = seleccionado
        ? (premium ? AppColors.brand400 : AppColors.brand500)
        : (premium ? AppColors.brand900 : AppColors.slate200);
    final checkColor = premium ? AppColors.brand400 : AppColors.brand500;
    final benefitColor = premium ? AppColors.slate200 : AppColors.slate600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: seleccionado ? 2.5 : 2,
        ),
        boxShadow: seleccionado
            ? <BoxShadow>[
                BoxShadow(
                  color: (premium ? AppColors.brand900 : AppColors.brand500)
                      .withAlpha(46),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  plan.nombre,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (plan.etiqueta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    plan.etiqueta!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.descripcion,
            style: TextStyle(
              color: descriptionColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                plan.precioFormateado,
                style: TextStyle(
                  color: priceColor,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  plan.esGratuito ? '/mes' : 'MXN /mes',
                  style: TextStyle(
                    color: periodColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final beneficio in plan.beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.check, size: 18, color: checkColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      beneficio,
                      style: TextStyle(
                        color: benefitColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: seleccionado
                    ? (premium ? Colors.white : AppColors.brand600)
                    : (premium ? AppColors.brand500 : AppColors.slate100),
                foregroundColor: seleccionado
                    ? (premium ? AppColors.brand700 : Colors.white)
                    : (premium ? Colors.white : AppColors.slate800),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                seleccionado
                    ? '✓ Seleccionado'
                    : plan.esGratuito
                        ? 'Comenzar gratis'
                        : 'Suscribirme ahora',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VentajaCompetitiva extends StatelessWidget {
  const _VentajaCompetitiva();

  static const List<_Competidor> _competidores = <_Competidor>[
    _Competidor(
      nombre: 'Photomath',
      enfoque: 'Le da la respuesta final al instante.',
      resultado: 'Dependencia',
      detalle:
          'Resuelve por el niño. No educa al papá ni desarrolla el razonamiento.',
      color: AppColors.red600,
      background: AppColors.red100,
    ),
    _Competidor(
      nombre: 'Khanmigo',
      enfoque: 'Conversa directamente con el alumno.',
      resultado: 'Otro usuario',
      detalle:
          'Está diseñado para el estudiante, no para que el padre acompañe la tarea.',
      color: AppColors.orange600,
      background: AppColors.orange100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.brand50,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.brand100),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'NUESTRO DIFERENCIADOR',
            style: TextStyle(
              color: AppColors.brand600,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hecho para papás, no para reemplazar al maestro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate900,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'EduGuía es un producto B2C exclusivo para padres de familia: '
            'te enseña el método y te da las preguntas correctas para que tú '
            'guíes a tu hijo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate600,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final width = isWide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final competidor in _competidores)
                    SizedBox(
                      width: width,
                      child: _CompetidorCard(data: competidor),
                    ),
                  SizedBox(width: width, child: const _EduGuiaCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final width = isWide
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _MetricaCard(
                    width: width,
                    value: 'Padres',
                    label: 'Usuario principal del producto',
                  ),
                  _MetricaCard(
                    width: width,
                    value: 'SEP',
                    label: 'Parametrización curricular',
                  ),
                  _MetricaCard(
                    width: width,
                    value: '0 respuestas',
                    label: 'Solo preguntas y acompañamiento',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompetidorCard extends StatelessWidget {
  const _CompetidorCard({required this.data});

  final _Competidor data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  data.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  data.resultado.toUpperCase(),
                  style: TextStyle(
                    color: data.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.enfoque,
            style: const TextStyle(
              color: AppColors.slate700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.detalle,
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EduGuiaCard extends StatelessWidget {
  const _EduGuiaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brand900,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brand500, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.brand900.withAlpha(46),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'EduGuía',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand400,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'B2C PADRES',
                  style: TextStyle(
                    color: AppColors.brand900,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Te explica el método SEP y te da preguntas guía.',
            style: TextStyle(
              color: AppColors.brand100,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No resuelve la tarea: acompaña al papá para que el niño descubra '
            'la respuesta y fortalezca su pensamiento crítico.',
            style: TextStyle(
              color: AppColors.brand200,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricaCard extends StatelessWidget {
  const _MetricaCard({
    required this.width,
    required this.value,
    required this.label,
  });

  final double width;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.brand100),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.brand700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmacionPlanDialog extends StatelessWidget {
  const _ConfirmacionPlanDialog({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final premium = plan.destacado;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: premium ? AppColors.brand100 : AppColors.green100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 34,
              color: premium ? AppColors.brand600 : AppColors.green600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            premium ? '¡Excelente elección!' : '¡Bienvenido!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Has seleccionado ${plan.nombre} '
            '(${plan.precioFormateado}${plan.esGratuito ? '' : ' MXN'}/mes). '
            '${plan.limiteTexto}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Entendido'),
          ),
        ),
      ],
    );
  }
}

class _Competidor {
  const _Competidor({
    required this.nombre,
    required this.enfoque,
    required this.resultado,
    required this.detalle,
    required this.color,
    required this.background,
  });

  final String nombre;
  final String enfoque;
  final String resultado;
  final String detalle;
  final Color color;
  final Color background;
}
