import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.dark = false,
    this.eyebrowColor = AppColors.brand600,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final bool dark;
  final Color eyebrowColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          eyebrow.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: eyebrowColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white : AppColors.slate900,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? AppColors.slate400 : AppColors.slate600,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
