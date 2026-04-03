import 'package:flutter/material.dart';

/// Quick actions row for the account overview screen.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Icon-only buttons with NO tooltip or semantics label
/// - 32x32 icon size in default IconButton creates targets below 48x48pt
/// - No visible text hints — screen readers announce only "button"
///
/// When [accessible] = true:
/// - Semantics labels on each button with descriptive label and hint
/// - Tooltip on each icon button
/// - 48x48 minimum touch targets
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, this.accessible = false});

  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Inaccessible: icon-only, no label/tooltip, small touch target
          IconButton(
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {},
          ),
          IconButton(
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.payment),
            onPressed: () {},
          ),
          IconButton(
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AccessibleActionButton(
            icon: Icons.swap_horiz,
            label: 'Transfer money',
            hint: 'Double tap to start a transfer',
            onPressed: () {},
          ),
          _AccessibleActionButton(
            icon: Icons.payment,
            label: 'Pay a bill',
            hint: 'Double tap to pay a bill',
            onPressed: () {},
          ),
          _AccessibleActionButton(
            icon: Icons.add,
            label: 'Add funds',
            hint: 'Double tap to add funds to your account',
            onPressed: () {},
          ),
          _AccessibleActionButton(
            icon: Icons.more_horiz,
            label: 'More actions',
            hint: 'Double tap to see more account actions',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// A single accessible quick-action button.
///
/// - 48x48 minimum touch target
/// - Semantics label and hint for screen readers
/// - Tooltip for pointer users
class _AccessibleActionButton extends StatelessWidget {
  const _AccessibleActionButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            iconSize: 28,
            padding: EdgeInsets.zero,
            icon: Icon(icon),
            // Exclude redundant semantics — parent Semantics node handles it
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
