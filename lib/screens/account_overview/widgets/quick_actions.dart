import 'package:flutter/material.dart';

/// Intentionally inaccessible quick actions row.
///
/// Accessibility failures demonstrated here:
/// - Icon-only buttons with NO tooltip or semantics label
/// - 32x32 icon size in default IconButton creates targets below 48x48pt
/// - No visible text hints — screen readers announce only "button"
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
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
}
