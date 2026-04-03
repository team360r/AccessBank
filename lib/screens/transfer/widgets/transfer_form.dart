import 'package:flutter/material.dart';

import '../../../data/mock_accounts.dart';
import '../../../data/models/account.dart';

/// Intentionally inaccessible transfer form.
///
/// Accessibility failures demonstrated here:
/// - Placeholder-only inputs — labels vanish on focus
/// - No validation feedback for screen readers
/// - Step summary (step 4) provides no semantic grouping
class TransferForm extends StatelessWidget {
  const TransferForm({
    super.key,
    required this.step,
    required this.fromAccount,
    required this.recipient,
    required this.amount,
    required this.note,
    required this.onFromAccountChanged,
    required this.onRecipientChanged,
    required this.onAmountChanged,
    required this.onNoteChanged,
  });

  final int step;
  final Account? fromAccount;
  final String recipient;
  final String amount;
  final String note;
  final ValueChanged<Account?> onFromAccountChanged;
  final ValueChanged<String> onRecipientChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: switch (step) {
        0 => _Step1FromAccount(
            fromAccount: fromAccount,
            onChanged: onFromAccountChanged,
          ),
        1 => _Step2Recipient(
            recipient: recipient,
            onChanged: onRecipientChanged,
          ),
        2 => _Step3Amount(
            amount: amount,
            note: note,
            onAmountChanged: onAmountChanged,
            onNoteChanged: onNoteChanged,
          ),
        3 => _Step4Summary(
            fromAccount: fromAccount,
            recipient: recipient,
            amount: amount,
            note: note,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Step1FromAccount extends StatelessWidget {
  const _Step1FromAccount({required this.fromAccount, required this.onChanged});

  final Account? fromAccount;
  final ValueChanged<Account?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Inaccessible: no label — screen readers only see current value
        DropdownButtonFormField<Account>(
          initialValue: fromAccount,
          hint: const Text('From account'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: MockAccounts.all
              .map(
                (a) => DropdownMenuItem(value: a, child: Text(a.name)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _Step2Recipient extends StatelessWidget {
  const _Step2Recipient({required this.recipient, required this.onChanged});

  final String recipient;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Inaccessible: placeholder-only — no persistent label
        TextField(
          decoration: const InputDecoration(
            hintText: 'Recipient name or account',
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _Step3Amount extends StatelessWidget {
  const _Step3Amount({
    required this.amount,
    required this.note,
    required this.onAmountChanged,
    required this.onNoteChanged,
  });

  final String amount;
  final String note;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Inaccessible: placeholder-only
        TextField(
          decoration: const InputDecoration(
            hintText: 'Amount',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: onAmountChanged,
        ),
        const SizedBox(height: 12),
        // Inaccessible: placeholder-only
        TextField(
          decoration: const InputDecoration(
            hintText: 'Note (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: onNoteChanged,
        ),
      ],
    );
  }
}

class _Step4Summary extends StatelessWidget {
  const _Step4Summary({
    required this.fromAccount,
    required this.recipient,
    required this.amount,
    required this.note,
  });

  final Account? fromAccount;
  final String recipient;
  final String amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    // Inaccessible: plain rows — no semantic grouping, no roles
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Confirm Transfer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _SummaryRow(label: 'From', value: fromAccount?.name ?? '—'),
        _SummaryRow(label: 'To', value: recipient.isEmpty ? '—' : recipient),
        _SummaryRow(
            label: 'Amount',
            value: amount.isEmpty ? '—' : '\$$amount'),
        if (note.isNotEmpty) _SummaryRow(label: 'Note', value: note),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
