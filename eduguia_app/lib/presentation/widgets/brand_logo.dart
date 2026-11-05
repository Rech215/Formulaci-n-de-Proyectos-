import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false, this.dark = false});

  final bool compact;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 40.0;
    final textColor = dark ? Colors.white : AppColors.slate900;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.brand500,
            borderRadius: BorderRadius.circular(compact ? 8 : 10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.brand500.withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'E',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 18 : 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: const <InlineSpan>[
              TextSpan(text: 'Edu'),
              TextSpan(
                text: 'Guía',
                style: TextStyle(color: AppColors.brand400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
