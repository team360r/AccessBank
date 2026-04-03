import 'package:flutter/material.dart';

/// Accessible and inaccessible color palettes for AccessBank.
///
/// [AppColors] contains two groups:
/// - Top-level statics: accessible colors meeting WCAG AA contrast ratios
///   (4.5:1 for normal text, 3:1 for large text).
/// - [inaccessible]: intentionally low-contrast colors used to demonstrate
///   accessibility problems in the "before" state of tutorial screens.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Accessible palette
  // ---------------------------------------------------------------------------

  /// Deep blue primary brand colour. Contrast ratio against white: ~7.3:1.
  static const Color primary = Color(0xFF1565C0);

  /// Lighter tint of primary, used for hover/focus states.
  static const Color primaryLight = Color(0xFF5E92F3);

  /// Default surface / background colour.
  static const Color surface = Color(0xFFFFFFFF);

  /// Error / destructive action colour.
  static const Color error = Color(0xFFB00020);

  /// High-emphasis body and headline text. Contrast on white: ~18.1:1.
  static const Color textPrimary = Color(0xFF121212);

  /// Medium-emphasis secondary text. Contrast on white: ~7.0:1.
  static const Color textSecondary = Color(0xFF555555);

  /// Success / confirmation colour.
  static const Color success = Color(0xFF2E7D32);

  /// Warning colour.
  static const Color warning = Color(0xFFE65100);

  // ---------------------------------------------------------------------------
  // Inaccessible palette (intentionally bad — for tutorial "before" state)
  // ---------------------------------------------------------------------------

  /// A nested group of deliberately low-contrast colour pairs that fail
  /// WCAG AA. These are used only on tutorial screens to demonstrate poor
  /// accessibility.
  static const inaccessible = _InaccessiblePalette();
}

/// Intentionally inaccessible colours.
///
/// All combinations in this class produce contrast ratios below 3:1 and are
/// WCAG failures. Do NOT use these outside of accessibility-demonstration
/// screens.
final class _InaccessiblePalette {
  const _InaccessiblePalette();

  /// Very light gray text on white background. Contrast ratio ~1.6:1.
  Color get textOnWhite => const Color(0xFFCCCCCC);

  /// Light blue text on white background. Contrast ratio ~2.0:1.
  Color get lightBlueOnWhite => const Color(0xFF90CAF9);

  /// Light gray background intended to carry important UI.
  Color get subtleSurface => const Color(0xFFF5F5F5);

  /// Low-contrast label text, nearly invisible on [subtleSurface].
  Color get labelOnSubtleSurface => const Color(0xFFBDBDBD);

  /// Pale green — fails contrast for text use. Contrast on white: ~1.5:1.
  Color get paleGreenOnWhite => const Color(0xFFA5D6A7);

  /// Washed-out orange on white. Contrast ratio ~1.9:1.
  Color get washedOrangeOnWhite => const Color(0xFFFFCC80);
}
