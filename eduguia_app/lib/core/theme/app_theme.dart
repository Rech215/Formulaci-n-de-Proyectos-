import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand600),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.slate50,
    cardColor: Colors.white,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brand600,
      onPrimary: Colors.white,
      secondary: AppColors.brand500,
      surface: Colors.white,
      onSurface: AppColors.slate900,
      error: AppColors.red600,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.slate900,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      surfaceTintColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.brand600,
      unselectedItemColor: AppColors.slate500,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.slate900,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.slate200),
  );
}
