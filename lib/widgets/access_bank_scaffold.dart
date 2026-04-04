import 'package:flutter/material.dart';

const List<String> _tabLabels = [
  'Overview', 'Transactions', 'Transfer', 'Settings',
];

const List<IconData> _tabIcons = [
  Icons.account_balance_outlined,
  Icons.receipt_long_outlined,
  Icons.swap_horiz_outlined,
  Icons.settings_outlined,
];

/// App shell with bottom navigation and optional tutorial nav lock.
///
/// When [allowedTabIndex] is non-null, all tabs except that index are
/// disabled and show a tooltip explaining which chapter covers them.
class AccessBankScaffold extends StatelessWidget {
  const AccessBankScaffold({
    super.key,
    required this.accessible,
    required this.currentIndex,
    required this.onTabChanged,
    required this.body,
    this.allowedTabIndex,
  });

  final bool accessible;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Widget body;

  /// Locks bottom nav to a specific tab. null = all tabs navigable.
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AccessBank')),
      body: body,
      bottomNavigationBar: accessible
          ? _AccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
              allowedTabIndex: allowedTabIndex,
            )
          : _InaccessibleNavBar(
              currentIndex: currentIndex,
              onTabChanged: onTabChanged,
              allowedTabIndex: allowedTabIndex,
            ),
    );
  }
}

class _AccessibleNavBar extends StatelessWidget {
  const _AccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.allowedTabIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    final total = _tabLabels.length;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (allowedTabIndex != null && i != allowedTabIndex) {
          _showLockedTooltip(context, i);
          return;
        }
        onTabChanged(i);
      },
      destinations: List.generate(total, (i) {
        final isSelected = i == currentIndex;
        final isLocked = allowedTabIndex != null && i != allowedTabIndex;
        final positionLabel =
            '${_tabLabels[i]} tab, ${i + 1} of $total, '
            '${isSelected ? "currently selected" : "not selected"}';

        return NavigationDestination(
          icon: Semantics(
            label: isLocked
                ? '${_tabLabels[i]} — locked during this tutorial step'
                : positionLabel,
            selected: isSelected,
            child: ExcludeSemantics(
              child: Icon(
                _tabIcons[i],
                color: isLocked ? Colors.grey.shade400 : null,
              ),
            ),
          ),
          label: _tabLabels[i],
        );
      }),
    );
  }

  void _showLockedTooltip(BuildContext context, int tabIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_tabLabels[tabIndex]} is covered in a later chapter. '
          'Follow the tutorial to get there.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _InaccessibleNavBar extends StatelessWidget {
  const _InaccessibleNavBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.allowedTabIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final int? allowedTabIndex;

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF5F5F5);
    const Color iconColor = Color(0xFFBDBDBD);
    const Color selectedColor = Color(0xFF90CAF9);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        if (allowedTabIndex != null && i != allowedTabIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_tabLabels[i]} is covered in a later chapter.'),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        onTabChanged(i);
      },
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
          label: '',
        ),
      ),
    );
  }
}
