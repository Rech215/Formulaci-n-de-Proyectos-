import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../state/session_provider.dart';
import 'app_drawer.dart';
import 'brand_logo.dart';
import 'plan_badge.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const List<_DestinoNav> _destinos = <_DestinoNav>[
    _DestinoNav(
      path: '/home',
      label: 'Inicio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _DestinoNav(
      path: '/escanear',
      label: 'Escanear',
      icon: Icons.document_scanner_outlined,
      activeIcon: Icons.document_scanner,
    ),
    _DestinoNav(
      path: '/history',
      label: 'Historial',
      icon: Icons.history_edu_outlined,
      activeIcon: Icons.history_edu,
    ),
    _DestinoNav(
      path: '/premium',
      label: 'Premium',
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium,
    ),
  ];

  int get _indiceActual {
    if (location.startsWith('/result')) return 1;
    if (location.startsWith('/premium')) return 3;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/escanear')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(compact: true),
        actions: <Widget>[
          Consumer<SessionProvider>(
            builder: (context, session, _) {
              if (!session.haySesion) return const SizedBox.shrink();
              final premium = session.esPremium;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: premium ? null : () => context.go('/premium'),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: PlanBadge(premium: premium),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (indice) => context.go(_destinos[indice].path),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          for (final destino in _destinos)
            NavigationDestination(
              icon: Icon(destino.icon),
              selectedIcon: Icon(destino.activeIcon, color: AppColors.brand700),
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
