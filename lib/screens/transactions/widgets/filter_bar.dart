import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Filter bar for the transactions screen.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Dropdown has no visible label — context lost for screen readers
/// - Sort toggle is icon-only with no tooltip or semantics label
/// - No announcement when sort order changes
///
/// When [accessible] = true:
/// - Dropdown has a labelled InputDecoration
/// - Sort toggle has a Tooltip and Semantics label
/// - SemanticsService.sendAnnouncement called when filter/sort changes
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.ascending,
    required this.onSortToggle,
    this.accessible = false,
    this.visibleCount = 0,
  });

  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final bool ascending;
  final VoidCallback onSortToggle;
  final bool accessible;

  /// Number of currently visible transactions (used for announcement).
  final int visibleCount;

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

  Widget _buildAccessibleVersion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            // Accessible: labelled dropdown using DropdownButtonFormField
            child: DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                ),
              ],
              onChanged: (val) {
                onCategoryChanged(val);
                final categoryLabel = val ?? 'all categories';
                final message =
                    'Showing $visibleCount transactions in $categoryLabel';
                SemanticsService.sendAnnouncement(
                  View.of(context),
                  message,
                  TextDirection.ltr,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // Accessible: sort button with Tooltip and Semantics label
          Semantics(
            label: ascending
                ? 'Sort by date, oldest first'
                : 'Sort by date, newest first',
            hint: 'Double tap to toggle sort order',
            button: true,
            child: Tooltip(
              message:
                  ascending ? 'Sort: oldest first' : 'Sort: newest first',
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    onSortToggle();
                    final order = ascending ? 'newest first' : 'oldest first';
                    SemanticsService.sendAnnouncement(
                      View.of(context),
                      'Sorted by date, $order',
                      TextDirection.ltr,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
