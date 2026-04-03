import 'package:flutter/material.dart';

import '../../data/mock_accounts.dart';
import '../../data/mock_transactions.dart';
import '../../data/models/transaction.dart';
import '../../theme/app_colors.dart';
import 'widgets/account_card.dart';
import 'widgets/quick_actions.dart';

/// Account overview screen for AccessBank.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - No semantic structure or grouping — heading is plain styled Text
/// - No semantic roles (no ExcludeSemantics, no Semantics wrappers)
/// - Recent transactions have no list count announcement
/// - Low-contrast colours throughout
///
/// When [accessible] = true:
/// - Semantics(header: true) on the greeting
/// - Semantics(liveRegion: true) on the balance area
/// - Semantic grouping for account section vs quick actions
/// - MergeSemantics on each account card
/// - Accessible colours and descriptive labels on transactions
class AccountOverviewScreen extends StatelessWidget {
  const AccountOverviewScreen({super.key, required this.accessible});

  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
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
          (txn) => _RecentTransactionTile(transaction: txn, accessible: false),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    final recentTransactions = MockTransactions.all.take(3).toList();

    return ListView(
      children: [
        const SizedBox(height: 16),
        // Accessible: Semantics(header: true) so screen readers announce as heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            header: true,
            child: const Text(
              'Good morning, Alex',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Accessible: accounts section grouped with a semantic label
        Semantics(
          label: 'Your accounts',
          child: Column(
            children: MockAccounts.all
                .map((account) => AccountCard(
                      account: account,
                      accessible: true,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Accessible: Quick actions section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            header: true,
            child: const Text(
              'Quick Actions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const QuickActions(accessible: true),
        const SizedBox(height: 8),
        // Accessible: Recent transactions section with count in header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            header: true,
            child: Text(
              'Recent Transactions (${recentTransactions.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        // Accessible: liveRegion wrapper so balance/transaction updates get announced
        Semantics(
          liveRegion: true,
          child: Column(
            children: recentTransactions
                .map(
                  (txn) => _RecentTransactionTile(
                    transaction: txn,
                    accessible: true,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Simple transaction tile used on the overview screen.
///
/// When [accessible] = false: colour-only credit/debit distinction, no semantic label.
/// When [accessible] = true: MergeSemantics, descriptive label, accessible colours.
class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({
    required this.transaction,
    required this.accessible,
  });

  final Transaction transaction;
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;

    if (accessible) {
      // Accessible: prefix amount with +/- and use accessible colour
      final amountPrefix = isCredit ? '+' : '-';
      final amountLabel = '$amountPrefix\$${transaction.amount.abs().toStringAsFixed(2)}';
      final typeLabel = isCredit ? 'Credit' : 'Debit';

      return MergeSemantics(
        child: Semantics(
          label: '$typeLabel ${transaction.merchant}, $amountLabel',
          child: ListTile(
            title: Text(
              transaction.merchant,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: Text(
              amountLabel,
              style: TextStyle(
                color: isCredit ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Inaccessible: colour-only indicator, low-contrast text
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
