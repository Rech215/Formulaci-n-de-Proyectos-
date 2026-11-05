import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/session_provider.dart';
import 'brand_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final padre = session.padre;
    final suscripcion = session.suscripcion;
    final restantes = suscripcion?.consultasRestantes;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[AppColors.brand700, AppColors.brand500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const BrandLogo(dark: true),
                  const SizedBox(height: 16),
                  Text(
                    padre?.nombre ?? 'Invitado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (padre != null)
                    Text(
                      padre.correo,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 13,
                      ),
                    ),
                  if (suscripcion != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        suscripcion.esPremium
                            ? 'Premium · Consultas ilimitadas'
                            : 'Gratuito · ${restantes ?? 0} de '
                                '${suscripcion.limiteConsultas ?? 0} consultas restantes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (session.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  session.error!,
                  style: const TextStyle(
                    color: AppColors.red600,
                    fontSize: 12,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  _drawerItem(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Inicio',
                    path: '/inicio',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.report_problem_outlined,
                    label: 'El problema',
                    path: '/problema',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    label: 'Cómo funciona',
                    path: '/como-funciona',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: 'Planes y precios',
                    path: '/planes',
                  ),
                  const Divider(height: 24),
                  _infoItem(context, Icons.receipt_long_outlined, 'Términos de servicio'),
                  _infoItem(context, Icons.shield_outlined, 'Privacidad de datos'),
                  _infoItem(context, Icons.mail_outline, 'Contacto'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '© 2026 Formulación de Proyectos\nEquipo UTM',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.slate500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate600),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate600),
      title: Text(label),
      onTap: () {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(content: Text('$label: información próximamente.')),
        );
      },
    );
  }
}
