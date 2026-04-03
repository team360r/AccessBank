import 'package:flutter/material.dart';

import '../../../data/models/account.dart';
import '../../../theme/app_colors.dart';

IconData _iconForType(AccountType type) {
  switch (type) {
    case AccountType.checking:
      return Icons.account_balance_wallet_outlined;
    case AccountType.savings:
      return Icons.savings_outlined;
    case AccountType.credit:
      return Icons.credit_card_outlined;
  }
}

String _typeLabel(AccountType type) {
  switch (type) {
    case AccountType.checking:
      return 'checking account';
    case AccountType.savings:
      return 'savings account';
    case AccountType.credit:
      return 'credit card';
  }
}

/// Spells out a currency amount for screen readers.
///
/// E.g. 4285.50 → "four thousand two hundred eighty-five dollars and fifty cents"
/// This is a simplified implementation for tutorial demonstration purposes.
String _spellOutAmount(double amount) {
  final isNegative = amount < 0;
  final abs = amount.abs();
  final dollars = abs.floor();
  final cents = ((abs - dollars) * 100).round();

  final dollarsText = _spellOutInteger(dollars);
  final sign = isNegative ? 'negative ' : '';

  if (cents == 0) {
    return '$sign$dollarsText dollars';
  }
  final centsText = _spellOutInteger(cents);
  return '$sign$dollarsText dollars and $centsText cents';
}

String _spellOutInteger(int n) {
  if (n == 0) return 'zero';
  if (n < 0) return 'negative ${_spellOutInteger(-n)}';

  const ones = [
    '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen',
  ];
  const tens = [
    '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy',
    'eighty', 'ninety',
  ];

  if (n < 20) return ones[n];
  if (n < 100) {
    return tens[n ~/ 10] + (n % 10 != 0 ? '-${ones[n % 10]}' : '');
  }
  if (n < 1000) {
    return '${ones[n ~/ 100]} hundred'
        '${n % 100 != 0 ? ' ${_spellOutInteger(n % 100)}' : ''}';
  }
  if (n < 1000000) {
    return '${_spellOutInteger(n ~/ 1000)} thousand'
        '${n % 1000 != 0 ? ' ${_spellOutInteger(n % 1000)}' : ''}';
  }
  return n.toString();
}

/// Account card widget.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Text uses [AppColors.inaccessible.lightBlueOnWhite] — fails WCAG 1.4.3 contrast
/// - No Semantics labels — screen readers see disconnected numbers/text
/// - Balance is a raw number with no currency or context for screen readers
///
/// When [accessible] = true:
/// - MergeSemantics wraps the card so screen reader reads it as one unit
/// - Descriptive label spells out the amount (e.g. "four thousand...")
/// - Accessible colour palette (AppColors.primary) for WCAG AA contrast
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    this.accessible = false,
  });

  final Account account;
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
    final inaccessible = AppColors.inaccessible;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _iconForType(account.type),
              // Inaccessible: low-contrast icon colour
              color: inaccessible.lightBlueOnWhite,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inaccessible: low-contrast text — ~2.0:1 on white
                  Text(
                    account.name,
                    style: TextStyle(
                      color: inaccessible.lightBlueOnWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Inaccessible: raw number, no currency label, low contrast
                  Text(
                    '\$${account.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: inaccessible.lightBlueOnWhite,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    final spokenLabel =
        '${account.name}, ${_typeLabel(account.type)}, '
        'balance ${_spellOutAmount(account.balance)}';

    return MergeSemantics(
      child: Semantics(
        label: spokenLabel,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Accessible: icon excluded from semantics (covered by MergeSemantics label)
                ExcludeSemantics(
                  child: Icon(
                    _iconForType(account.type),
                    // Accessible: high-contrast primary colour
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Accessible: high-contrast text
                      Text(
                        account.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Accessible: high-contrast balance text
                      Text(
                        '\$${account.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                    ],
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
