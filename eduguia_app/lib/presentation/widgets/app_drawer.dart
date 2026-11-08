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
    final premium = session.esPremium;

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
                      premium
                          ? 'Premium · Sin anuncios'
                          : 'Gratis · Escaneos con anuncios',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (padre != null && padre.hijos.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      padre.hijos
                          .map(
                            (hijo) => '${hijo.nombre} · ${hijo.gradoEscolar}',
                          )
                          .join('\n'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 12,
                        height: 1.5,
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
                  style: const TextStyle(color: AppColors.red600, fontSize: 12),
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
                    icon: Icons.document_scanner_outlined,
                    label: 'Escanear tarea',
                    path: '/escanear',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.history_edu_outlined,
                    label: 'Historial',
                    path: '/historial',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: premium ? 'Tu plan Premium' : 'Quitar anuncios',
                    path: '/premium',
                  ),
                  const Divider(height: 24),
                  _drawerItem(
                    context,
                    icon: Icons.shield_outlined,
                    label: 'Aviso de privacidad',
                    path: '/legal/privacidad',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: 'Términos de servicio',
                    path: '/legal/terminos',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.mail_outline,
                    label: 'Contacto',
                    path: '/legal/contacto',
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.red600),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: AppColors.red600),
                    ),
                    onTap: () => _cerrarSesion(context, session),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '© 2026 EduGuía\nAcompaña, no resuelvas.',
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
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.go(path);
      },
    );
  }

  Future<void> _cerrarSesion(
    BuildContext context,
    SessionProvider session,
  ) async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Quieres salir de tu cuenta? Tu historial local se conservará.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red600),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    navigator.pop();
    await session.cerrarSesion();
    router.go('/login');
  }
}
