import 'package:flutter/material.dart';

import '../../../data/models/account.dart';
import '../../../theme/app_colors.dart';

/// Intentionally inaccessible account card.
///
/// Accessibility failures demonstrated here:
/// - Text uses [AppColors.inaccessible.lightBlueOnWhite] — fails WCAG 1.4.3 contrast
/// - No Semantics labels — screen readers see disconnected numbers/text
/// - Balance is a raw number with no currency or context for screen readers
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

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
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
}
