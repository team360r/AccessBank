import 'package:flutter/material.dart';

import '../chapter_model.dart';
import 'code_diff_viewer.dart';
import 'try_it_prompt.dart';
import 'why_callout.dart';

/// Renders a single [TutorialStep] with all its optional sub-widgets.
///
/// Includes:
/// - A numbered header ("Step 3 of 5" + title)
/// - Explanation prose
/// - Optional [CodeDiffViewer] if the step has a [CodeDiff]
/// - Optional [WhyCallout] if [TutorialStep.whyItMatters] is set
/// - Optional [TryItPrompt] if [TutorialStep.tryItPrompt] is set
/// - Reference link chips
class StepCard extends StatelessWidget {
  const StepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
  });

  final TutorialStep step;
  final int stepNumber;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // Step header
            // ---------------------------------------------------------------
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Step $stepNumber of $totalSteps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ---------------------------------------------------------------
            // Explanation
            // ---------------------------------------------------------------
            Text(
              step.explanation,
              style: theme.textTheme.bodyMedium,
            ),

            // ---------------------------------------------------------------
            // Code diff (if present)
            // ---------------------------------------------------------------
            if (step.codeDiff != null) ...[
              const SizedBox(height: 16),
              CodeDiffViewer(diff: step.codeDiff!),
            ],

            // ---------------------------------------------------------------
            // Why it matters callout
            // ---------------------------------------------------------------
            if (step.whyItMatters != null)
              WhyCallout(text: step.whyItMatters!),

            // ---------------------------------------------------------------
            // Try it prompt
            // ---------------------------------------------------------------
            if (step.tryItPrompt != null)
              TryItPrompt(text: step.tryItPrompt!),

            // ---------------------------------------------------------------
            // Reference links
            // ---------------------------------------------------------------
            if (step.referenceLinks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final link in step.referenceLinks)
                    Semantics(
                      label: 'Reference link: $link',
                      button: true,
                      child: ActionChip(
                        label: Text(
                          _shortenUrl(link),
                          style: const TextStyle(fontSize: 11),
                        ),
                        avatar: const Icon(Icons.link, size: 14),
                        onPressed: () {
                          // url_launcher is not a dependency — show a snackbar
                          // with the full URL instead.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(link),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Copy',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Shortens a URL to a readable label.
  String _shortenUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.replaceFirst('www.', '');
      final path = uri.pathSegments.lastOrNull ?? '';
      return path.isEmpty ? host : '$host/…/$path';
    } catch (_) {
      return url.length > 40 ? '${url.substring(0, 37)}…' : url;
    }
  }
}
