import 'package:flutter/material.dart';

import '../../data/mock_transactions.dart';
import '../../data/models/transaction.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_tile.dart';

/// Intentionally inaccessible transactions screen.
///
/// Accessibility failures demonstrated here:
/// - No list count announcement ("Showing 20 transactions")
/// - No sort change feedback for screen readers
/// - Filter bar lacks labels
/// - Dismissible items have no alternative button
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      children: [
        FilterBar(
          selectedCategory: _selectedCategory,
          categories: _allCategories,
          onCategoryChanged: (val) =>
              setState(() => _selectedCategory = val),
          ascending: _ascending,
          onSortToggle: () => setState(() => _ascending = !_ascending),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final txn = filtered[index];
              return TransactionTile(
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
