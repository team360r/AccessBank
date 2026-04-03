import 'package:flutter/material.dart';

import '../../data/models/account.dart';
import 'widgets/transfer_form.dart';
import 'widgets/transfer_stepper.dart';

/// Intentionally inaccessible multi-step transfer screen.
///
/// Accessibility failures demonstrated here:
/// - Stepper communicates progress by colour only
/// - Form fields use placeholder-only labels
/// - No screen reader announcements on step transitions
/// - Confirm dialog is a basic AlertDialog with no live region
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
    } else {
      _confirm();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
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
        TransferStepper(currentStep: _currentStep),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: TransferForm(
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
