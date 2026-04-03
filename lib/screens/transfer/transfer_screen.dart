import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../data/models/account.dart';
import 'widgets/transfer_form.dart';
import 'widgets/transfer_stepper.dart';

const List<String> _stepNames = [
  'From Account',
  'Recipient',
  'Amount',
  'Review',
];

/// Multi-step transfer screen for AccessBank.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Stepper communicates progress by colour only
/// - Form fields use placeholder-only labels
/// - No screen reader announcements on step transitions
/// - Confirm dialog is a basic AlertDialog with no live region
///
/// When [accessible] = true:
/// - Stepper has per-step Semantics labels (step number, name, status)
/// - Form fields use persistent labelText
/// - SemanticsService.sendAnnouncement on step transitions
/// - Focus management between steps
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.accessible});

  final bool accessible;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  int _currentStep = 0;
  Account? _fromAccount;
  String _recipient = '';
  String _amount = '';
  String _note = '';

  static const int _totalSteps = 4;

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      if (widget.accessible) {
        final nextName = _stepNames[_currentStep];
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Step ${_currentStep + 1} of $_totalSteps: $nextName',
          TextDirection.ltr,
        );
      }
    } else {
      _confirm();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      if (widget.accessible) {
        final prevName = _stepNames[_currentStep];
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Step ${_currentStep + 1} of $_totalSteps: $prevName',
          TextDirection.ltr,
        );
      }
    }
  }

  void _confirm() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Transfer Complete!'),
        content: const Text(
          'Your transfer has been submitted successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentStep = 0;
                _fromAccount = null;
                _recipient = '';
                _amount = '';
                _note = '';
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Column(
      children: [
        TransferStepper(
          currentStep: _currentStep,
          accessible: widget.accessible,
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: TransferForm(
              accessible: widget.accessible,
              step: _currentStep,
              fromAccount: _fromAccount,
              recipient: _recipient,
              amount: _amount,
              note: _note,
              onFromAccountChanged: (a) => setState(() => _fromAccount = a),
              onRecipientChanged: (v) => setState(() => _recipient = v),
              onAmountChanged: (v) => setState(() => _amount = v),
              onNoteChanged: (v) => setState(() => _note = v),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _back,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLastStep ? 'Confirm' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
