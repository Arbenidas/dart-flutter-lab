import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color paper = Color(0xFFF4F0E6);
  static const Color ink = Color(0xFF151515);
  static const Color acid = Color(0xFFBEFF33);
  static const Color coral = Color(0xFFFF6B57);
  static const Color blue = Color(0xFF69A7FF);
}

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.acid,
      brightness: Brightness.light,
      surface: AppColors.paper,
    ),
    fontFamily: 'monospace',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 52,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
      ),
      headlineMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(color: AppColors.ink, height: 1.5),
      bodyMedium: TextStyle(color: AppColors.ink, height: 1.45),
      labelLarge: TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.4,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: AppColors.ink),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.ink, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.ink, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.ink, width: 4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
        backgroundColor: const WidgetStatePropertyAll(AppColors.acid),
        overlayColor: WidgetStatePropertyAll(
          AppColors.ink.withValues(alpha: 0.08),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: AppColors.ink, width: 2),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ),
  );
}
