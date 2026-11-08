import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/state/onboarding_provider.dart';
import '../../presentation/state/session_provider.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/history_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/legal/contact_view.dart';
import '../../presentation/views/legal/privacy_view.dart';
import '../../presentation/views/legal/terms_view.dart';
import '../../presentation/views/not_found_view.dart';
import '../../presentation/views/onboarding_view.dart';
import '../../presentation/views/premium_view.dart';
import '../../presentation/views/result_view.dart';
import '../../presentation/views/scan_view.dart';
import '../../presentation/widgets/app_shell.dart';

abstract class AppRouter {
  static GoRouter create({
    required SessionProvider session,
    required OnboardingProvider onboarding,
  }) {
    final refresh = Listenable.merge(<Listenable>[session, onboarding]);

    return GoRouter(
      initialLocation: '/inicio',
      refreshListenable: refresh,
      redirect: (context, state) {
        final path = state.uri.path;
        final enOnboarding = path == '/onboarding';
        final enAuth = path == '/login' || path == '/registro';
        final enLegal = path.startsWith('/legal/');

        if (onboarding.cargando) return '/onboarding';
        if (!onboarding.completado && !enOnboarding) return '/onboarding';
        if (onboarding.completado && enOnboarding) {
          return session.haySesion ? '/inicio' : '/login';
        }
        if (enLegal) return null;
        if (!session.haySesion && !enAuth) return '/login';
        if (session.haySesion && enAuth) return '/inicio';
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          pageBuilder: (context, state) =>
              _page(state, const OnboardingView(), fullscreen: true),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) =>
              _page(state, const LoginView(), fullscreen: true),
        ),
        GoRoute(
          path: '/registro',
          name: 'registro',
          pageBuilder: (context, state) =>
              _page(state, const RegisterView(), fullscreen: true),
        ),
        GoRoute(
          path: '/legal/privacidad',
          name: 'privacidad',
          pageBuilder: (context, state) =>
              _page(state, const PrivacyView(), fullscreen: true),
        ),
        GoRoute(
          path: '/legal/terminos',
          name: 'terminos',
          pageBuilder: (context, state) =>
              _page(state, const TermsView(), fullscreen: true),
        ),
        GoRoute(
          path: '/legal/contacto',
          name: 'contacto',
          pageBuilder: (context, state) =>
              _page(state, const ContactView(), fullscreen: true),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return AppShell(location: state.uri.path, child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/inicio',
              name: 'inicio',
              pageBuilder: (context, state) => _page(state, const HomeView()),
            ),
            GoRoute(
              path: '/escanear',
              name: 'escanear',
              pageBuilder: (context, state) => _page(state, const ScanView()),
            ),
            GoRoute(
              path: '/historial',
              name: 'historial',
              pageBuilder: (context, state) =>
                  _page(state, const HistoryView()),
            ),
            GoRoute(
              path: '/resultado',
              name: 'resultado',
              pageBuilder: (context, state) => _page(state, const ResultView()),
            ),
            GoRoute(
              path: '/premium',
              name: 'premium',
              pageBuilder: (context, state) =>
                  _page(state, const PremiumView()),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => const NotFoundView(),
    );
  }

  static CustomTransitionPage<void> _page(
    GoRouterState state,
    Widget child, {
    bool fullscreen = false,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration(milliseconds: fullscreen ? 360 : 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(fullscreen ? 0 : 0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
