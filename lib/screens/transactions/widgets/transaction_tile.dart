import 'package:flutter/material.dart';

import '../../../data/models/transaction.dart';

const List<String> _monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Groceries':
      return Icons.local_grocery_store_outlined;
    case 'Dining':
      return Icons.restaurant_outlined;
    case 'Shopping':
      return Icons.shopping_bag_outlined;
    case 'Income':
      return Icons.attach_money_outlined;
    case 'Rent':
      return Icons.home_outlined;
    case 'Transfer':
      return Icons.swap_horiz_outlined;
    case 'Utilities':
      return Icons.bolt_outlined;
    case 'ATM':
      return Icons.atm_outlined;
    case 'Entertainment':
      return Icons.movie_outlined;
    case 'Travel':
      return Icons.flight_outlined;
    case 'Transportation':
      return Icons.directions_car_outlined;
    case 'Health':
      return Icons.local_pharmacy_outlined;
    case 'Subscriptions':
      return Icons.subscriptions_outlined;
    default:
      return Icons.receipt_outlined;
  }
}

/// Returns the spoken type label for a transaction type.
String _typeLabel(TransactionType type) {
  switch (type) {
    case TransactionType.debit:
      return 'Debit';
    case TransactionType.credit:
      return 'Credit';
    case TransactionType.transfer:
      return 'Transfer';
  }
}

/// Transaction tile for the transactions screen.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Debit/credit distinction is colour-only (green/red) — fails WCAG 1.4.1
/// - Dismissible widget provides swipe-to-delete with NO alternative button
/// - No semantic label combining merchant, amount, and type for screen readers
///
/// When [accessible] = true:
/// - MergeSemantics wraps the entire tile
/// - Full semantic label: type, amount, merchant, date
/// - Trailing delete IconButton as an alternative to swipe-to-delete
/// - Dismissible is kept for sighted users; button alternative for everyone else
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDismissed,
    this.accessible = false,
  });

  final Transaction transaction;
  final VoidCallback onDismissed;
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    // Inaccessible: colour-only distinction between credit and debit
    final amountColor = isCredit ? Colors.green : Colors.red;
    final formattedDate =
        '${transaction.date.month}/${transaction.date.day}/${transaction.date.year}';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      // Inaccessible: no alternative delete button for non-swipe users
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        leading: Icon(_categoryIcon(transaction.category)),
        title: Text(transaction.merchant),
        subtitle: Text(formattedDate),
        trailing: Text(
          '£${transaction.amount.abs().toStringAsFixed(2)}',
          // Inaccessible: colour-only indicator — screen readers won't say debit/credit
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final typeStr = _typeLabel(transaction.type);
    final amountStr = '£${transaction.amount.abs().toStringAsFixed(2)}';
    final monthName = _monthNames[transaction.date.month];
    final spokenDate = '$monthName ${transaction.date.day}';

    // Full semantic label: "Debit, twenty-three pounds, Grocery Store, April first"
    final semanticLabel =
        '$typeStr, $amountStr, ${transaction.merchant}, $spokenDate';

    // Accessible: keep Dismissible for sighted swipe users AND add a delete button
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: MergeSemantics(
        child: Semantics(
          label: semanticLabel,
          child: ListTile(
            leading: ExcludeSemantics(
              child: Icon(_categoryIcon(transaction.category)),
            ),
            title: Text(transaction.merchant),
            subtitle: Text('$monthName ${transaction.date.day}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Accessible: +/- prefix for screen readers (not colour-only)
                ExcludeSemantics(
                  child: Text(
                    '${isCredit ? '+' : '-'}$amountStr',
                    style: TextStyle(
                      color: isCredit ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Accessible: explicit delete button as alternative to swipe
                Semantics(
                  label: 'Delete transaction: ${transaction.merchant}',
                  button: true,
                  excludeSemantics: true,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    onPressed: onDismissed,
                    tooltip: 'Delete transaction',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
