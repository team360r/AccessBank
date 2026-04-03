import 'package:flutter/material.dart';

import '../../../data/models/transaction.dart';

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

/// Intentionally inaccessible transaction tile.
///
/// Accessibility failures demonstrated here:
/// - Debit/credit distinction is colour-only (green/red) — fails WCAG 1.4.1
/// - Dismissible widget provides swipe-to-delete with NO alternative button
/// - No semantic label combining merchant, amount, and type for screen readers
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDismissed,
  });

  final Transaction transaction;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
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
          '\$${transaction.amount.abs().toStringAsFixed(2)}',
          // Inaccessible: colour-only indicator — screen readers won't say debit/credit
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
