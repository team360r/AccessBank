import 'package:flutter/material.dart';

import '../chapter_model.dart';
import '../tutorial_controller.dart';

/// Renders a [Quiz] as an interactive card with radio-button questions,
/// answer submission, scoring, and a "Try Again" reset option.
class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    required this.chapterId,
    required this.controller,
  });

  final Quiz quiz;
  final int chapterId;
  final TutorialController controller;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  /// Selected answer index per question. -1 means unanswered.
  late List<int> _selections;
  bool _submitted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _selections = List.filled(widget.quiz.questions.length, -1);
    _submitted = false;
    _score = 0;
  }

  void _submit() {
    int correct = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_selections[i] == widget.quiz.questions[i].correctIndex) {
        correct++;
      }
    }
    setState(() {
      _score = correct;
      _submitted = true;
    });
    widget.controller.submitQuiz(widget.chapterId, correct);
  }

  bool get _allAnswered => _selections.every((s) => s != -1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = widget.quiz.questions;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // Title
            // ---------------------------------------------------------------
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.quiz.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // Score banner (shown after submission)
            // ---------------------------------------------------------------
            if (_submitted) ...[
              _ScoreBanner(
                score: _score,
                total: questions.length,
              ),
              const SizedBox(height: 16),
            ],

            // ---------------------------------------------------------------
            // Questions
            // ---------------------------------------------------------------
            for (int qi = 0; qi < questions.length; qi++) ...[
              _QuestionCard(
                question: questions[qi],
                questionIndex: qi,
                selectedIndex: _selections[qi],
                submitted: _submitted,
                onSelected: _submitted
                    ? null
                    : (v) => setState(() => _selections[qi] = v),
              ),
              if (qi < questions.length - 1) const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),

            // ---------------------------------------------------------------
            // Action buttons
            // ---------------------------------------------------------------
            Row(
              children: [
                if (_submitted) ...[
                  TextButton.icon(
                    onPressed: () => setState(_reset),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                  const Spacer(),
                ] else ...[
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _allAnswered ? _submit : null,
                    child: const Text('Check Answers'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score banner
// ---------------------------------------------------------------------------

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isPerfect = score == total;
    final color = isPerfect ? Colors.green.shade700 : Colors.orange.shade700;
    final bgColor = isPerfect
        ? Colors.green.shade50
        : Colors.orange.shade50;

    return Semantics(
      liveRegion: true,
      label: 'Quiz result: $score of $total correct',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(128)),
        ),
        child: Row(
          children: [
            Icon(
              isPerfect ? Icons.star_rounded : Icons.info_outline,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              '$score of $total correct!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual question card
// ---------------------------------------------------------------------------

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.questionIndex,
    required this.selectedIndex,
    required this.submitted,
    required this.onSelected,
  });

  final QuizQuestion question;
  final int questionIndex;
  final int selectedIndex;
  final bool submitted;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect =
        submitted && selectedIndex == question.correctIndex;
    final isWrong =
        submitted && selectedIndex != question.correctIndex && selectedIndex != -1;

    Color borderColor = theme.colorScheme.outlineVariant;
    if (isCorrect) borderColor = Colors.green.shade600;
    if (isWrong) borderColor = Colors.red.shade600;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: isCorrect || isWrong ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              'Q${questionIndex + 1}: ${question.question}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Options — wrapped in RadioGroup to avoid deprecated groupValue API
          _OptionsGroup(
            question: question,
            selectedIndex: selectedIndex,
            submitted: submitted,
            onSelected: onSelected,
          ),

          // Explanation (after submission)
          if (submitted) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Options group — uses RadioGroup ancestor to manage group value
// ---------------------------------------------------------------------------

class _OptionsGroup extends StatelessWidget {
  const _OptionsGroup({
    required this.question,
    required this.selectedIndex,
    required this.submitted,
    required this.onSelected,
  });

  final QuizQuestion question;
  final int selectedIndex;
  final bool submitted;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: selectedIndex == -1 ? null : selectedIndex,
      onChanged: onSelected != null
          ? (int? v) { if (v != null) onSelected!(v); }
          : (int? v) {},
      child: Column(
        children: [
          for (int oi = 0; oi < question.options.length; oi++)
            _buildOption(oi),
        ],
      ),
    );
  }

  Widget _buildOption(int oi) {
    Color? tileColor;
    if (submitted) {
      if (oi == question.correctIndex) {
        tileColor = Colors.green.shade50;
      } else if (oi == selectedIndex) {
        tileColor = Colors.red.shade50;
      }
    }

    return ListTile(
      dense: true,
      tileColor: tileColor,
      leading: Radio<int>(value: oi),
      title: Text(question.options[oi], style: const TextStyle(fontSize: 13)),
      onTap: onSelected != null ? () => onSelected!(oi) : null,
    );
  }
}
