import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Main Bokku Mart brand colour.
  static const Color primary = Color(0xFF6D28D9);

  /// Darker brand purple.
  static const Color primaryDark = Color(0xFF4C1D95);

  /// Lighter brand purple.
  static const Color primaryLight = Color(0xFF8B5CF6);

  /// Soft purple background.
  static const Color primarySoft = Color(0xFFF3E8FF);

  /// Backward-compatible semantic name used throughout the existing UI.
  ///
  /// This now maps to the new purple design system.
  static const Color primarySurface = primarySoft;

  // ---------------------------------------------------------------------------
  // Secondary brand colours
  // ---------------------------------------------------------------------------

  /// Secondary accent for places that previously used the old secondary colour.
  static const Color secondary = primaryLight;

  /// Soft secondary background.
  static const Color secondaryLight = Color(0xFFEDE9FE);

  // ---------------------------------------------------------------------------
  // Backgrounds / surfaces
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF9FAFB);

  /// Raised cards, sheets and elevated content.
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Very soft purple surface for highlighted sections.
  static const Color surfacePurple = Color(0xFFFAF5FF);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF18181B);

  static const Color textSecondary = Color(0xFF71717A);

  /// Muted captions, placeholders and inactive navigation.
  static const Color textMuted = Color(0xFFA1A1AA);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Borders / dividers
  // ---------------------------------------------------------------------------

  static const Color border = Color(0xFFE4E4E7);

  // ---------------------------------------------------------------------------
  // Semantic status colours
  // ---------------------------------------------------------------------------

  /// Keep success green.
  ///
  /// Used for:
  /// - email verified
  /// - phone verified
  /// - in stock
  /// - successful payment
  /// - completed order
  static const Color success = Color(0xFF16A34A);

  static const Color successSurface = Color(0xFFF0FDF4);

  /// Warning / attention state.
  static const Color warning = Color(0xFFF59E0B);

  static const Color warningSurface = Color(0xFFFFFBEB);

  /// Errors and destructive actions.
  static const Color error = Color(0xFFDC2626);

  static const Color errorSurface = Color(0xFFFEF2F2);

  // ---------------------------------------------------------------------------
  // Deals / promotions
  // ---------------------------------------------------------------------------

  /// Discounts remain red so they visually stand apart from the purple brand.
  static const Color discount = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // Backward compatibility
  // ---------------------------------------------------------------------------

  /// Old name retained while the UI is progressively migrated.
  static const Color accentRed = error;

  /// Old red surface retained for existing widgets.
  static const Color accentRedSurface = errorSurface;
}
