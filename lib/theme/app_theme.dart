import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Provides Material 3 [ThemeData] for AccessBank.
///
/// Use [lightTheme] as the app's default theme and [darkTheme] for dark mode.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: _buildTextTheme(Brightness.light),
        scaffoldBackgroundColor: AppColors.surface,
      );

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          error: AppColors.error,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
      );

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Returns a [TextTheme] with all body styles set to a minimum of 14sp.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color defaultColor =
        brightness == Brightness.light ? AppColors.textPrimary : Colors.white;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.w400, color: defaultColor),
      displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.w400, color: defaultColor),
      displaySmall: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w400, color: defaultColor),

      // Headline styles
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w600, color: defaultColor),
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600, color: defaultColor),
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: defaultColor),

      // Title styles
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: defaultColor),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: defaultColor),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: defaultColor),

      // Body styles — minimum 14sp
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: defaultColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: defaultColor),
      bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: brightness == Brightness.light
              ? AppColors.textSecondary
              : Colors.white70),

      // Label styles — minimum 14sp
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: defaultColor),
      labelMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: defaultColor),
      labelSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: defaultColor),
    );
  }
}
