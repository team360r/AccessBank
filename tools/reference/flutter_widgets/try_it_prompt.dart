import 'package:flutter/material.dart';

/// A blue/teal callout prompting the learner to try something in the app.
///
/// Includes an optional "I've tried this" checkbox that the learner can
/// check to track their own progress.
class TryItPrompt extends StatefulWidget {
  const TryItPrompt({super.key, required this.text});

  final String text;

  @override
  State<TryItPrompt> createState() => _TryItPromptState();
}

class _TryItPromptState extends State<TryItPrompt> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA), // cyan 50
        border: Border.all(color: const Color(0xFF80DEEA)), // cyan 200
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.pan_tool_outlined,
                color: Color(0xFF00838F), // cyan 800
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try it yourself',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00838F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF004D5A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: "I've tried this",
            checked: _checked,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => setState(() => _checked = !_checked),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _checked,
                    onChanged: (v) => setState(() => _checked = v ?? false),
                    activeColor: const Color(0xFF00838F),
                  ),
                  Text(
                    "I've tried this",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF004D5A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
