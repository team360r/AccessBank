import 'package:flutter/material.dart';

/// An amber/yellow callout box explaining why an accessibility fix matters.
///
/// Used within [StepCard] whenever a [TutorialStep] has a non-null
/// [whyItMatters] field.
class WhyCallout extends StatelessWidget {
  const WhyCallout({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Why this matters: $text',
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1), // amber 50
          border: Border.all(color: const Color(0xFFFFD54F)), // amber 300
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFFF57F17), // amber 900
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why this matters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5D4037), // brown 700
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
