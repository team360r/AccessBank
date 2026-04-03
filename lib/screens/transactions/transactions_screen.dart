import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../data/mock_transactions.dart';
import '../../data/models/transaction.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_tile.dart';

/// Transactions screen for AccessBank.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - No list count announcement ("Showing 20 transactions")
/// - No sort change feedback for screen readers
/// - Filter bar lacks labels
/// - Dismissible items have no alternative button
///
/// When [accessible] = true:
/// - Announces list count after filter/sort changes
/// - Filter bar uses labelled DropdownButtonFormField
/// - Sort button has Semantics label and Tooltip
/// - TransactionTile has MergeSemantics and a delete button alternative
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.accessible});

  final bool accessible;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedCategory;
  bool _ascending = false;
  late List<Transaction> _transactions;

  static final List<String> _allCategories = MockTransactions.all
      .map((t) => t.category)
      .toSet()
      .toList()
    ..sort();

  @override
  void initState() {
    super.initState();
    _transactions = List.of(MockTransactions.all);
  }

  List<Transaction> get _filtered {
    var list = _selectedCategory == null
        ? List.of(_transactions)
        : _transactions
            .where((t) => t.category == _selectedCategory)
            .toList();
    list.sort(
      (a, b) => _ascending
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date),
    );
    return list;
  }

  void _remove(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  void _announceSortChange() {
    if (!widget.accessible) return;
    final filtered = _filtered;
    final order = _ascending ? 'oldest first' : 'newest first';
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Showing ${filtered.length} transactions, sorted by date, $order',
      TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      children: [
        FilterBar(
          accessible: widget.accessible,
          selectedCategory: _selectedCategory,
          categories: _allCategories,
          visibleCount: filtered.length,
          onCategoryChanged: (val) =>
              setState(() => _selectedCategory = val),
          ascending: _ascending,
          onSortToggle: () {
            setState(() => _ascending = !_ascending);
            _announceSortChange();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final txn = filtered[index];
              return TransactionTile(
                accessible: widget.accessible,
                transaction: txn,
                onDismissed: () => _remove(txn.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
