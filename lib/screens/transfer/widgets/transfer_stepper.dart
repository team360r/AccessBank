import 'package:flutter/material.dart';

/// Intentionally inaccessible transfer stepper.
///
/// Accessibility failures demonstrated here:
/// - Purely visual coloured dots — no text labels on steps
/// - No Semantics indicating which step is current or how many steps there are
/// - Past/future steps communicated by colour alone (WCAG 1.4.1 failure)
class TransferStepper extends StatelessWidget {
  const TransferStepper({super.key, required this.currentStep});

  /// 0-based current step index. Range: 0–3.
  final int currentStep;

  static const _stepCount = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Row(
        children: List.generate(_stepCount * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line between dots
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < currentStep ? Colors.blue : Colors.grey[300],
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final isPast = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          // Inaccessible: colour-only state — no semantic label or role
          Color dotColor;
          Widget dotContent;
          if (isPast) {
            dotColor = Colors.blue;
            dotContent = const Icon(Icons.check, color: Colors.white, size: 14);
          } else if (isCurrent) {
            dotColor = Colors.blue;
            dotContent = const SizedBox.shrink();
          } else {
            dotColor = Colors.grey[300]!;
            dotContent = const SizedBox.shrink();
          }

          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: dotContent),
          );
        }),
      ),
    );
  }
}
