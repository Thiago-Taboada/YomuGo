import 'package:flutter/material.dart';

/// Colores alineados al mockup (oscuro + acento violeta).
abstract final class AppColors {
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF12161D);
  static const Color surfaceInput = Color(0xFF1A1F2A);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentMuted = Color(0xFF6D28D9);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color kanjiWatermark = Color(0x1AFFFFFF);
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: Colors.white,
      error: const Color(0xFFF87171),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
