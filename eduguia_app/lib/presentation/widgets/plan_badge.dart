import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.premium});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    final color = premium ? AppColors.brand700 : AppColors.slate600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: premium ? AppColors.brand50 : AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: premium ? AppColors.brand200 : AppColors.slate200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            premium ? Icons.workspace_premium : Icons.person_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            premium ? 'Premium' : 'Gratuito',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
