import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.explore_off_outlined,
                size: 64,
                color: AppColors.brand600,
              ),
              const SizedBox(height: 16),
              const Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'La ruta que buscas no existe en EduGuía.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate600),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/inicio'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
