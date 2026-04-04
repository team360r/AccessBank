import 'package:flutter/material.dart';

import '../tutorial_controller.dart';

/// Shows progress through the current chapter and the overall tutorial.
///
/// Displays a [LinearProgressIndicator], a "Step X of Y" label, the chapter
/// title, and the overall tutorial completion percentage.
class TutorialProgressBar extends StatelessWidget {
  const TutorialProgressBar({super.key, required this.controller});

  final TutorialController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (controller.chapters.isEmpty) {
      return const SizedBox.shrink();
    }

    final chapter = controller.currentChapter;
    final stepIndex = controller.currentStepIndex;
    final totalSteps = chapter.steps.length;

    final stepProgress =
        totalSteps == 0 ? 0.0 : (stepIndex + 1) / totalSteps;
    final overallPct = (controller.overallProgress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step progress bar for this chapter
        Semantics(
          label:
              'Chapter progress: step ${stepIndex + 1} of $totalSteps',
          child: LinearProgressIndicator(
            value: stepProgress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              totalSteps == 0
                  ? chapter.title
                  : 'Step ${stepIndex + 1} of $totalSteps  ·  ${chapter.title}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '$overallPct% complete',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
