import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/views/home_view.dart';
import '../../presentation/views/how_it_works_view.dart';
import '../../presentation/views/not_found_view.dart';
import '../../presentation/views/pricing_view.dart';
import '../../presentation/views/problem_view.dart';
import '../../presentation/widgets/app_shell.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/inicio',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.isEmpty || path == '/') return '/inicio';
      return null;
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/inicio',
            name: 'inicio',
            pageBuilder: (context, state) =>
                _page(state, const HomeView()),
          ),
          GoRoute(
            path: '/problema',
            name: 'problema',
            pageBuilder: (context, state) =>
                _page(state, const ProblemView()),
          ),
          GoRoute(
            path: '/como-funciona',
            name: 'como-funciona',
            pageBuilder: (context, state) =>
                _page(state, const HowItWorksView()),
          ),
          GoRoute(
            path: '/planes',
            name: 'planes',
            pageBuilder: (context, state) =>
                _page(state, const PricingView()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundView(),
  );

  static CustomTransitionPage<void> _page(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
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
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
