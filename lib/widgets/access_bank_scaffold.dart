import 'package:flutter/material.dart';

/// Labels for the four main navigation tabs.
const List<String> _tabLabels = [
  'Overview',
  'Transactions',
  'Transfer',
  'Settings',
];

/// Icons for the four main navigation tabs.
const List<IconData> _tabIcons = [
  Icons.account_balance_outlined,
  Icons.receipt_long_outlined,
  Icons.swap_horiz_outlined,
  Icons.settings_outlined,
];

/// App shell that wraps post-login screens with a [BottomNavigationBar].
///
/// Pass [accessible] = true to render the navigation bar with WCAG AA-compliant
/// colours and visible text labels. Pass [accessible] = false (the default in
/// the tutorial "before" state) to render an intentionally inaccessible variant
/// that uses low-contrast colours and shows only icons — no labels.
class AccessBankScaffold extends StatelessWidget {
  const AccessBankScaffold({
    super.key,
    required this.accessible,
    required this.currentIndex,
    required this.onTabChanged,
    required this.body,
  });

  /// Controls whether the accessible or inaccessible variant is rendered.
  final bool accessible;

  /// The currently selected tab index (0-based).
  final int currentIndex;

  /// Called when the user taps a tab.
  final ValueChanged<int> onTabChanged;

  /// The content to display above the navigation bar.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: accessible
          ? _AccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
            )
          : _InaccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accessible nav bar — proper contrast + labels
// ---------------------------------------------------------------------------

class _AccessibleNavBar extends StatelessWidget {
  const _AccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabChanged,
      destinations: List.generate(
        _tabLabels.length,
        (i) => NavigationDestination(
          icon: Icon(_tabIcons[i]),
          label: _tabLabels[i],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inaccessible nav bar — low-contrast, icon-only (no labels)
// ---------------------------------------------------------------------------

/// Intentionally inaccessible navigation bar.
///
/// Accessibility failures demonstrated here:
/// - No text labels (icon-only) — violates WCAG 2.4.6 Headings and Labels
/// - Low-contrast background / icon colours — fails WCAG 1.4.3 Contrast
/// - No semantic tooltip or meaning beyond the icon glyph
class _InaccessibleNavBar extends StatelessWidget {
  const _InaccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    // Intentionally bad colours — both fail WCAG AA contrast ratios.
    const Color background = Color(0xFFF5F5F5); // AppColors.inaccessible.subtleSurface
    const Color iconColor = Color(0xFFBDBDBD);  // AppColors.inaccessible.labelOnSubtleSurface
    const Color selectedColor = Color(0xFF90CAF9); // lightBlueOnWhite — ~2.0:1 on white

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      backgroundColor: background,
      unselectedItemColor: iconColor,
      selectedItemColor: selectedColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: List.generate(
        _tabLabels.length,
        (i) => BottomNavigationBarItem(
          icon: Icon(_tabIcons[i]),
          // Empty string label — never shown but required by the API.
          label: '',
        ),
      ),
    );
  }
}
