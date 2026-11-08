import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Construye el [ThemeData] global de EduGuía.
///
/// Paleta primaria Teal/Turquesa, fondo Slate 50,
/// tipografías legibles y bordes redondeados consistentes.
ThemeData buildAppTheme() {
  // ── Tipografía ──────────────────────────────────────────────────────────
  const fontFamily = 'Segoe UI';

  final textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.slate900,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.slate900,
      letterSpacing: -0.5,
      height: 1.18,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.slate900,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.slate900,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.slate900,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.slate900,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.slate900,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.slate900,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.slate900,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.slate600,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.slate900,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.slate600,
      letterSpacing: 0.4,
    ),
  ).apply(fontFamily: fontFamily);

  // ── Color scheme base ───────────────────────────────────────────────────
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand600),
    fontFamily: fontFamily,
  );

  // ── Bordes redondeados reutilizables ────────────────────────────────────
  const cardRadius = 20.0;
  const inputRadius = 14.0;
  const buttonRadius = 14.0;
  const dialogRadius = 24.0;
  const chipRadius = 999.0;

  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  return base.copyWith(
    // ── Colores globales ────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.slate50,
    cardColor: Colors.white,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brand600,
      onPrimary: Colors.white,
      secondary: AppColors.brand500,
      surface: Colors.white,
      onSurface: AppColors.slate900,
      error: AppColors.red600,
    ),

    // ── AppBar ──────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.slate900,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      surfaceTintColor: Colors.white,
    ),

    // ── BottomNavigationBar ─────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.brand600,
      unselectedItemColor: AppColors.slate500,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),

    // ── Card ────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: AppColors.slate200),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── InputDecoration ─────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.brand500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.red500),
      ),
      hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
    ),

    // ── Dialog ──────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogRadius),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),

    // ── FilledButton ────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand600,
        foregroundColor: Colors.white,
        padding: buttonPadding,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),

    // ── OutlinedButton ──────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.slate700,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.slate200),
        padding: buttonPadding,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),

    // ── ElevatedButton ──────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.brand700,
        backgroundColor: AppColors.brand50,
        elevation: 0,
        padding: buttonPadding,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),

    // ── TextButton ──────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brand600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),

    // ── Chip ────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.brand50,
      side: const BorderSide(color: AppColors.brand100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipRadius),
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: AppColors.brand700,
      ),
    ),

    // ── SnackBar ────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.slate900,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── Divider ─────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(color: AppColors.slate200),
  );
}
