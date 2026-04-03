import 'package:flutter/material.dart';

import '../../data/mock_accounts.dart';
import '../../data/mock_transactions.dart';
import '../../data/models/transaction.dart';
import '../../theme/app_colors.dart';
import 'widgets/account_card.dart';
import 'widgets/quick_actions.dart';

/// Intentionally inaccessible account overview screen.
///
/// Accessibility failures demonstrated here:
/// - No semantic structure or grouping — heading is plain styled Text
/// - No semantic roles (no ExcludeSemantics, no Semantics wrappers)
/// - Recent transactions have no list count announcement
/// - Low-contrast colours throughout
class AccountOverviewScreen extends StatelessWidget {
  const AccountOverviewScreen({super.key, required this.accessible});

  final bool accessible;

  @override
  Widget build(BuildContext context) {
    final recentTransactions = MockTransactions.all.take(3).toList();

    return ListView(
      children: [
        const SizedBox(height: 16),
        // Inaccessible: greeting is plain Text, not a semantic heading
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Good morning, Alex',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        // Account cards — no semantic grouping
        ...MockAccounts.all.map((account) => AccountCard(account: account)),
        const SizedBox(height: 8),
        // Inaccessible: section label is plain Text, no semantic header role
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const QuickActions(),
        const SizedBox(height: 8),
        // Inaccessible: section label is plain Text, no semantic header role
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        // Inaccessible: no list count announcement, plain tiles
        ...recentTransactions.map(
          (txn) => _RecentTransactionTile(transaction: txn),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Simple transaction tile used on the overview screen.
///
/// Inaccessible: colour-only credit/debit distinction, no semantic label.
class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final amountColor = isCredit ? Colors.green : Colors.red;

    return ListTile(
      // Inaccessible: low-contrast title colour
      title: Text(
        transaction.merchant,
        style: TextStyle(color: AppColors.inaccessible.lightBlueOnWhite),
      ),
      // Inaccessible: colour-only indicator — no +/- prefix for screen readers
      trailing: Text(
        '\$${transaction.amount.abs().toStringAsFixed(2)}',
        style: TextStyle(color: amountColor),
      ),
    );
  }
}
