import 'package:flutter/material.dart';

import 'tutorial_controller.dart';
import 'widgets/chapter_list.dart';
import 'widgets/progress_bar.dart';
import 'widgets/step_card.dart';

/// Responsive tutorial overlay that wraps a banking content widget.
///
/// Layout behaviour:
/// - Width >= 800 px: side-by-side [Row] — tutorial panel (flex 2) on the
///   left, banking content (flex 3) on the right.
/// - Width < 800 px: banking content fills the screen; the tutorial panel
///   appears as a [DraggableScrollableSheet] anchored to the bottom.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.controller,
    required this.bankingContent,
  });

  final TutorialController controller;

  /// The banking app widget shown alongside or beneath the tutorial panel.
  final Widget bankingContent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return _WideLayout(
                controller: controller,
                bankingContent: bankingContent,
              );
            }
            return _NarrowLayout(
              controller: controller,
              bankingContent: bankingContent,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout — side-by-side
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.controller,
    required this.bankingContent,
  });

  final TutorialController controller;
  final Widget bankingContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _TutorialPanel(controller: controller),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: bankingContent,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow layout — banking content full-width + draggable bottom sheet
// ---------------------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.controller,
    required this.bankingContent,
  });

  final TutorialController controller;
  final Widget bankingContent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bankingContent,
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.08,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.08, 0.38, 0.92],
          builder: (context, scrollController) {
            return Material(
              elevation: 8,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: _TutorialPanel(
                controller: controller,
                scrollController: scrollController,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tutorial panel — shared content for both layouts
// ---------------------------------------------------------------------------

class _TutorialPanel extends StatelessWidget {
  const _TutorialPanel({
    required this.controller,
    this.scrollController,
  });

  final TutorialController controller;

  /// Provided by [DraggableScrollableSheet] in narrow mode; null in wide mode.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ----------------------------------------------------------------
        // Drag handle (narrow mode only)
        // ----------------------------------------------------------------
        if (scrollController != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

        // ----------------------------------------------------------------
        // Header: chapter title + inspector toggle
        // ----------------------------------------------------------------
        Container(
          color: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.chapters.isEmpty
                      ? 'Tutorial'
                      : controller.currentChapter.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Inspector toggle button
              Semantics(
                label: controller.showInspector
                    ? 'Hide accessibility inspector'
                    : 'Show accessibility inspector',
                button: true,
                child: IconButton(
                  icon: Icon(
                    controller.showInspector
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white,
                  ),
                  tooltip: controller.showInspector
                      ? 'Hide inspector'
                      : 'Show inspector',
                  onPressed: controller.toggleInspector,
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------------------------------------
        // Progress bar
        // ----------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TutorialProgressBar(controller: controller),
        ),

        // ----------------------------------------------------------------
        // Scrollable step content
        // ----------------------------------------------------------------
        Expanded(
          child: controller.chapters.isEmpty
              ? const Center(child: Text('Loading tutorial…'))
              : ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  children: [
                    StepCard(
                      step: controller.currentStep,
                      stepNumber: controller.currentStepIndex + 1,
                      totalSteps: controller.currentChapter.steps.length,
                    ),
                  ],
                ),
        ),

        // ----------------------------------------------------------------
        // Before / After toggle
        // ----------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text('Before'),
              Switch(
                value: controller.showAccessible,
                onChanged: (_) => controller.toggleAccessible(),
              ),
              const Text('After'),
              const Spacer(),
              Text(
                controller.showAccessible ? 'Accessible' : 'Inaccessible',
                style: TextStyle(
                  fontSize: 11,
                  color: controller.showAccessible
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),

        // ----------------------------------------------------------------
        // Chapter list toggle
        // ----------------------------------------------------------------
        _ChapterListToggle(controller: controller),

        // ----------------------------------------------------------------
        // Prev / Next navigation
        // ----------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed:
                    _canGoPrev(controller) ? controller.previousStep : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Prev'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: controller.chapters.isEmpty ? null : controller.nextStep,
                icon: const Icon(Icons.chevron_right),
                label: Text(_nextLabel(controller)),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _canGoPrev(TutorialController c) {
    return c.currentStepIndex > 0 || c.currentChapterIndex > 0;
  }

  String _nextLabel(TutorialController c) {
    if (c.chapters.isEmpty) return 'Next';
    final ch = c.currentChapter;
    if (c.currentStepIndex >= ch.steps.length - 1) {
      if (c.currentChapterIndex >= c.chapters.length - 1) {
        return 'Finish';
      }
      return 'Next Chapter';
    }
    return 'Next';
  }
}

// ---------------------------------------------------------------------------
// Collapsible chapter list section
// ---------------------------------------------------------------------------

class _ChapterListToggle extends StatefulWidget {
  const _ChapterListToggle({required this.controller});

  final TutorialController controller;

  @override
  State<_ChapterListToggle> createState() => _ChapterListToggleState();
}

class _ChapterListToggleState extends State<_ChapterListToggle> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.list_alt_outlined, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'All Chapters',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          SizedBox(
            height: 240,
            child: ChapterList(controller: widget.controller),
          ),
      ],
    );
  }
}
