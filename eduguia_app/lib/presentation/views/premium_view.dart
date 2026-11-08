import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/suscripcion.dart';
import '../state/session_provider.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  static const List<String> _beneficios = <String>[
    'Escaneos ilimitados',
    'Sin anuncios entre tareas',
    'Preguntas guía adaptadas a la edad',
    'Alineación curricular SEP',
    'Historial de tareas en el dispositivo',
    'Ideas de juegos para la vida diaria',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, session, _) {
        final premium = session.esPremium;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (premium)
                      _buildActivo(context, session)
                    else
                      _buildOferta(),
                    const SizedBox(height: 18),
                    _buildBeneficios(premium),
                    const SizedBox(height: 18),
                    if (!premium) ...<Widget>[
                      FilledButton.icon(
                        onPressed:
                            session.cargando ? null : session.comprarPremium,
                        icon: const Icon(Icons.workspace_premium_outlined),
                        label: session.cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Activar Premium · '
                                '\$${Suscripcion.precioPremiumMxn}/mes',
                              ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed:
                          session.cargando ? null : session.restaurarCompras,
                      icon: const Icon(Icons.restore),
                      label: const Text('Restaurar compras'),
                    ),
                    if (session.error != null) ...<Widget>[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.red100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          session.error!,
                          style: const TextStyle(
                            color: AppColors.red600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      premium
                          ? 'Puedes restaurar tu compra si cambias de '
                              'dispositivo o reinstalas la app.'
                          : 'El pago se gestiona de forma segura con la '
                              'tienda de tu dispositivo. Puedes cancelar '
                              'cuando quieras.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 11,
                        height: 1.5,
                      ),
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

  Widget _buildOferta() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'SIN ANUNCIOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'EduGuía Premium',
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
            'Acompaña a tu hijo sin interrupciones y con más herramientas '
            'para cada tarea.',
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                '\$${Suscripcion.precioPremiumMxn}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'MXN / mes',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivo(BuildContext context, SessionProvider session) {
    final suscripcion = session.suscripcion;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.brand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.green100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppColors.green600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Premium activo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Disfruta escaneos sin anuncios y todas las herramientas de '
            'acompañamiento.',
            style: TextStyle(
              color: AppColors.slate500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (suscripcion?.fechaRenovacion != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Próxima renovación: '
              '${_fecha(suscripcion!.fechaRenovacion!)}',
              style: const TextStyle(
                color: AppColors.brand700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/escanear'),
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Escanear una tarea'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficios(bool premium) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            premium ? 'Todo lo que ya tienes' : 'Todo lo que incluye',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 14),
          for (final beneficio in _beneficios)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.green500,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      beneficio,
                      style: const TextStyle(
                        color: AppColors.slate700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _fecha(DateTime fecha) {
    const meses = <String>[
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}
