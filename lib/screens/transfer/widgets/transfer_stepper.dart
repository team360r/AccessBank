import 'package:flutter/material.dart';

const List<String> _stepNames = ['From Account', 'Recipient', 'Amount', 'Review'];

/// Transfer stepper showing progress through the 4-step transfer flow.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Purely visual coloured dots — no text labels on steps
/// - No Semantics indicating which step is current or how many steps there are
/// - Past/future steps communicated by colour alone (WCAG 1.4.1 failure)
///
/// When [accessible] = true:
/// - Each dot has Semantics: "Step N of 4: Name, status" (completed/in progress/upcoming)
/// - Step labels are visible below each dot
/// - SemanticsService.sendAnnouncement announced on step transitions via [onStepChanged]
class TransferStepper extends StatelessWidget {
  const TransferStepper({
    super.key,
    required this.currentStep,
    this.accessible = false,
  });

  /// 0-based current step index. Range: 0–3.
  final int currentStep;
  final bool accessible;

  static const _stepCount = 4;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
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

  Widget _buildAccessibleVersion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: List.generate(_stepCount * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
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
          final stepNumber = stepIndex + 1;
          final stepName = _stepNames[stepIndex];

          String status;
          if (isPast) {
            status = 'completed';
          } else if (isCurrent) {
            status = 'in progress';
          } else {
            status = 'upcoming';
          }

          // Accessible: full semantic label for each step dot
          final semanticLabel =
              'Step $stepNumber of $_stepCount: $stepName, $status';

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

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: semanticLabel,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: dotContent),
                  ),
                ),
                const SizedBox(height: 4),
                // Visible step label
                Text(
                  stepName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.blue : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
