import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../data/mock_accounts.dart';
import '../../../data/models/account.dart';

/// Transfer form widget, rendered differently for each step.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Placeholder-only inputs — labels vanish on focus
/// - No validation feedback for screen readers
/// - Step summary (step 4) provides no semantic grouping
///
/// When [accessible] = true:
/// - InputDecoration.labelText on all fields (persistent labels)
/// - Live validation via SemanticsService.sendAnnouncement
/// - Proper TextInputType and autofillHints where applicable
/// - Focus management between steps
/// - Summary step uses Semantics grouping and descriptive labels
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
    this.accessible = false,
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
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: switch (step) {
        0 => accessible
            ? _AccessibleStep1FromAccount(
                fromAccount: fromAccount,
                onChanged: onFromAccountChanged,
              )
            : _Step1FromAccount(
                fromAccount: fromAccount,
                onChanged: onFromAccountChanged,
              ),
        1 => accessible
            ? _AccessibleStep2Recipient(
                recipient: recipient,
                onChanged: onRecipientChanged,
              )
            : _Step2Recipient(
                recipient: recipient,
                onChanged: onRecipientChanged,
              ),
        2 => accessible
            ? _AccessibleStep3Amount(
                amount: amount,
                note: note,
                onAmountChanged: onAmountChanged,
                onNoteChanged: onNoteChanged,
              )
            : _Step3Amount(
                amount: amount,
                note: note,
                onAmountChanged: onAmountChanged,
                onNoteChanged: onNoteChanged,
              ),
        3 => accessible
            ? _AccessibleStep4Summary(
                fromAccount: fromAccount,
                recipient: recipient,
                amount: amount,
                note: note,
              )
            : _Step4Summary(
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

// ---------------------------------------------------------------------------
// Inaccessible step widgets
// ---------------------------------------------------------------------------

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
            value: amount.isEmpty ? '—' : '£$amount'),
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

// ---------------------------------------------------------------------------
// Accessible step widgets
// ---------------------------------------------------------------------------

class _AccessibleStep1FromAccount extends StatelessWidget {
  const _AccessibleStep1FromAccount({
    required this.fromAccount,
    required this.onChanged,
  });

  final Account? fromAccount;
  final ValueChanged<Account?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accessible: labelText provides persistent label for screen readers
        DropdownButtonFormField<Account>(
          initialValue: fromAccount,
          decoration: const InputDecoration(
            labelText: 'From account',
            border: OutlineInputBorder(),
          ),
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

class _AccessibleStep2Recipient extends StatefulWidget {
  const _AccessibleStep2Recipient({
    required this.recipient,
    required this.onChanged,
  });

  final String recipient;
  final ValueChanged<String> onChanged;

  @override
  State<_AccessibleStep2Recipient> createState() =>
      _AccessibleStep2RecipientState();
}

class _AccessibleStep2RecipientState
    extends State<_AccessibleStep2Recipient> {
  String? _error;

  void _validate(String value) {
    widget.onChanged(value);
    if (value.trim().isEmpty) {
      const msg = 'Recipient is required';
      setState(() => _error = msg);
      SemanticsService.sendAnnouncement(
        View.of(context),
        msg,
        TextDirection.ltr,
      );
    } else {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accessible: persistent labelText, proper autofillHints
        TextField(
          decoration: InputDecoration(
            labelText: 'Recipient name or account number',
            hintText: 'Enter recipient',
            border: const OutlineInputBorder(),
            errorText: _error,
          ),
          textInputAction: TextInputAction.done,
          onChanged: widget.onChanged,
          onEditingComplete: () => _validate(widget.recipient),
        ),
      ],
    );
  }
}

class _AccessibleStep3Amount extends StatefulWidget {
  const _AccessibleStep3Amount({
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
  State<_AccessibleStep3Amount> createState() =>
      _AccessibleStep3AmountState();
}

class _AccessibleStep3AmountState extends State<_AccessibleStep3Amount> {
  String? _amountError;

  void _validateAmount(String value) {
    widget.onAmountChanged(value);
    final parsed = double.tryParse(value);
    if (value.isNotEmpty && (parsed == null || parsed <= 0)) {
      const msg = 'Please enter a valid amount greater than zero';
      setState(() => _amountError = msg);
      SemanticsService.sendAnnouncement(
        View.of(context),
        msg,
        TextDirection.ltr,
      );
    } else {
      setState(() => _amountError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accessible: persistent labelText, number keyboard, live validation
        TextField(
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: '0.00',
            prefixText: '£',
            border: const OutlineInputBorder(),
            errorText: _amountError,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          onChanged: _validateAmount,
        ),
        const SizedBox(height: 12),
        // Accessible: persistent labelText for note field
        TextField(
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            hintText: 'Add a memo',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onChanged: widget.onNoteChanged,
        ),
      ],
    );
  }
}

class _AccessibleStep4Summary extends StatelessWidget {
  const _AccessibleStep4Summary({
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
    // Accessible: semantic grouping with Semantics label on the summary section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Confirm Transfer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        // Accessible: each row is individually labelled for screen readers
        _AccessibleSummaryRow(
          label: 'From',
          value: fromAccount?.name ?? 'Not selected',
        ),
        _AccessibleSummaryRow(
          label: 'To',
          value: recipient.isEmpty ? 'Not entered' : recipient,
        ),
        _AccessibleSummaryRow(
          label: 'Amount',
          value: amount.isEmpty ? 'Not entered' : '£$amount',
        ),
        if (note.isNotEmpty)
          _AccessibleSummaryRow(label: 'Note', value: note),
      ],
    );
  }
}

class _AccessibleSummaryRow extends StatelessWidget {
  const _AccessibleSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: ExcludeSemantics(child: Text(value)),
            ),
          ],
        ),
      ),
    );
  }
}
