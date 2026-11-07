import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/session_provider.dart';
import '../widgets/brand_logo.dart';
import 'app_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const List<_DestinoNav> _destinos = <_DestinoNav>[
    _DestinoNav(
      path: '/inicio',
      label: 'Inicio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _DestinoNav(
      path: '/problema',
      label: 'Problema',
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem,
    ),
    _DestinoNav(
      path: '/como-funciona',
      label: 'Cómo funciona',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    _DestinoNav(
      path: '/historial',
      label: 'Historial',
      icon: Icons.history_edu_outlined,
      activeIcon: Icons.history_edu,
    ),
    _DestinoNav(
      path: '/planes',
      label: 'Planes',
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium,
    ),
  ];

  int get _indiceActual {
    final indice = _destinos.indexWhere(
      (destino) => location.startsWith(destino.path),
    );
    return indice < 0 ? 0 : indice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(compact: true),
        actions: <Widget>[
          Consumer<SessionProvider>(
            builder: (context, session, _) {
              if (!session.haySesion ||
                  MediaQuery.sizeOf(context).width < 360) {
                return const SizedBox.shrink();
              }
              final premium = session.suscripcion?.esPremium ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  avatar: Icon(
                    premium ? Icons.workspace_premium : Icons.person_outline,
                    size: 16,
                    color: AppColors.brand700,
                  ),
                  label: Text(
                    premium ? 'Premium' : 'Gratuito',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand700,
                    ),
                  ),
                  backgroundColor: AppColors.brand50,
                  side: const BorderSide(color: AppColors.brand100),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceActual,
        onTap: (indice) => context.go(_destinos[indice].path),
        items: <BottomNavigationBarItem>[
          for (final destino in _destinos)
            BottomNavigationBarItem(
              icon: Icon(destino.icon),
              activeIcon: Icon(destino.activeIcon),
              label: destino.label,
            ),
        ],
      ),
    );
  }
}

class _DestinoNav {
  const _DestinoNav({
    required this.path,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
