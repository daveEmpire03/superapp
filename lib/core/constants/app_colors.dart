import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Main Bokku Mart brand colour — pure blue.
  static const Color primary = Color(0xFF0000FF);

  /// Darker brand blue.
  static const Color primaryDark = Color(0xFF0000CC);

  /// Lighter brand blue.
  static const Color primaryLight = Color(0xFF4D4DFF);

  /// Soft blue background.
  static const Color primarySoft = Color(0xFFEEEEFF);

  /// Backward-compatible semantic name.
  static const Color primarySurface = primarySoft;

  // ---------------------------------------------------------------------------
  // Secondary brand colours
  // ---------------------------------------------------------------------------

  static const Color secondary = primaryLight;

  /// Soft secondary blue background.
  static const Color secondaryLight = Color(0xFFE0E0FF);

  // ---------------------------------------------------------------------------
  // Backgrounds / surfaces
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF9FAFB);

  /// Raised cards, sheets and elevated content.
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Very soft blue surface for highlighted sections.
  static const Color surfacePurple = Color(0xFFF5F5FF);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF18181B);

  static const Color textSecondary = Color(0xFF71717A);

  static const Color textMuted = Color(0xFFA1A1AA);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Borders / dividers
  // ---------------------------------------------------------------------------

  static const Color border = Color(0xFFE4E4E7);

  // ---------------------------------------------------------------------------
  // Semantic status colours
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF16A34A);

  static const Color successSurface = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFF59E0B);

  static const Color warningSurface = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFDC2626);

  static const Color errorSurface = Color(0xFFFEF2F2);

  // ---------------------------------------------------------------------------
  // Deals / promotions
  // ---------------------------------------------------------------------------

  static const Color discount = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // Backward compatibility
  // ---------------------------------------------------------------------------

  static const Color accentRed = error;

  static const Color accentRedSurface = errorSurface;
}
