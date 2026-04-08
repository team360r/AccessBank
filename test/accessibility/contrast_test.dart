import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// WCAG contrast ratio utilities
// ---------------------------------------------------------------------------

/// Calculates the relative luminance of a [Color] per WCAG 2.1 formula.
///
/// Formula: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double _relativeLuminance(Color color) {
  double linearise(double component) {
    final c = component;
    return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearise(color.r);
  final g = linearise(color.g);
  final b = linearise(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Returns the contrast ratio between two colours.
///
/// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 >= L2.
double contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

// ---------------------------------------------------------------------------
// WCAG thresholds
// ---------------------------------------------------------------------------

/// WCAG AA minimum contrast ratio for normal text (< 18pt or < 14pt bold).
const double kWcagAANormal = 4.5;

/// WCAG AA minimum contrast ratio for large text (>= 18pt or >= 14pt bold).
const double kWcagAALarge = 3.0;

void main() {
  group('Accessible palette — WCAG AA contrast', () {
    test('primary on white meets AA for large text (>= 3:1)', () {
      final ratio = contrastRatio(AppColors.primary, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAALarge),
          reason:
              'AppColors.primary (#1565C0) on white should be >= 3:1 for large text. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('primary on white meets AA for normal text (>= 4.5:1)', () {
      final ratio = contrastRatio(AppColors.primary, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAANormal),
          reason:
              'AppColors.primary (#1565C0) on white should be >= 4.5:1 for normal text. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('textPrimary on white meets AA for normal text', () {
      final ratio = contrastRatio(AppColors.textPrimary, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAANormal),
          reason:
              'AppColors.textPrimary on white should meet AA. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('textSecondary on white meets AA for normal text', () {
      final ratio = contrastRatio(AppColors.textSecondary, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAANormal),
          reason:
              'AppColors.textSecondary on white should meet AA. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('error colour on white meets AA for normal text', () {
      final ratio = contrastRatio(AppColors.error, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAANormal),
          reason:
              'AppColors.error on white should meet AA. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('success colour on white meets AA for normal text', () {
      final ratio = contrastRatio(AppColors.success, AppColors.surface);
      expect(ratio, greaterThanOrEqualTo(kWcagAANormal),
          reason:
              'AppColors.success on white should meet AA. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });
  });

  group('Inaccessible palette — intentionally FAILS WCAG AA', () {
    // These tests assert that the deliberately-bad colours DO fail WCAG.
    // They act as a canary — if someone accidentally improves these colours
    // without updating the tutorial, these tests will catch it.

    test('lightBlueOnWhite FAILS AA for normal text (contrast < 4.5:1)', () {
      final ratio = contrastRatio(
        AppColors.inaccessible.lightBlueOnWhite,
        AppColors.surface,
      );
      expect(ratio, lessThan(kWcagAANormal),
          reason:
              'inaccessible.lightBlueOnWhite should intentionally fail AA (< 4.5:1). '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('textOnWhite FAILS AA for normal text (contrast < 4.5:1)', () {
      final ratio = contrastRatio(
        AppColors.inaccessible.textOnWhite,
        AppColors.surface,
      );
      expect(ratio, lessThan(kWcagAANormal),
          reason:
              'inaccessible.textOnWhite should intentionally fail AA (< 4.5:1). '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });

    test('labelOnSubtleSurface FAILS AA for normal text', () {
      final ratio = contrastRatio(
        AppColors.inaccessible.labelOnSubtleSurface,
        AppColors.inaccessible.subtleSurface,
      );
      expect(ratio, lessThan(kWcagAANormal),
          reason:
              'inaccessible label on subtle surface should fail AA. '
              'Got: ${ratio.toStringAsFixed(2)}:1');
    });
  });

  group('Contrast ratio utility function', () {
    test('identical colours have contrast ratio of 1:1', () {
      final ratio = contrastRatio(Colors.black, Colors.black);
      expect(ratio, closeTo(1.0, 0.001));
    });

    test('black on white has maximum contrast ratio ~21:1', () {
      final ratio = contrastRatio(Colors.black, Colors.white);
      expect(ratio, greaterThan(20.0));
    });

    test('ratio is symmetric (order does not matter)', () {
      final ab = contrastRatio(AppColors.primary, AppColors.surface);
      final ba = contrastRatio(AppColors.surface, AppColors.primary);
      expect(ab, closeTo(ba, 0.001));
    });
  });
}
