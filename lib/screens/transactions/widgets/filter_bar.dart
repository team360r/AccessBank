import 'package:flutter/material.dart';

/// Intentionally inaccessible filter bar.
///
/// Accessibility failures demonstrated here:
/// - Dropdown has no visible label — context lost for screen readers
/// - Sort toggle is icon-only with no tooltip or semantics label
/// - No announcement when sort order changes
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.ascending,
    required this.onSortToggle,
  });

  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final bool ascending;
  final VoidCallback onSortToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              // Inaccessible: no label — screen readers announce value only
              value: selectedCategory,
              isExpanded: true,
              hint: const Text('All'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                ),
              ],
              onChanged: onCategoryChanged,
            ),
          ),
          const SizedBox(width: 8),
          // Inaccessible: icon-only sort button, no label, no change announcement
          IconButton(
            icon: Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: onSortToggle,
          ),
        ],
      ),
    );
  }
}
