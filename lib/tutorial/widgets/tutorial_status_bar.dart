import 'package:flutter/material.dart';
import '../tutorial_app_state.dart';

/// Compact status bar shown at the top of every screen when the tutorial
/// server is in use. Shows chapter/step position and connection status.
///
/// Tapping opens a small detail overlay with connection info.
class TutorialStatusBar extends StatelessWidget {
  const TutorialStatusBar({super.key, required this.state});

  final TutorialAppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => _showDetails(context),
          child: Container(
            width: double.infinity,
            color: state.isConnected
                ? const Color(0xFF1565C0) // dark blue when connected
                : const Color(0xFF616161), // grey when disconnected
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isConnected ? Colors.greenAccent : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.isConnected
                        ? 'Ch ${state.chapterIndex + 1} · Step ${state.stepIndex + 1}/${state.totalSteps}'
                        : 'Connecting to tutorial...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (state.isConnected && state.chapterTitle.isNotEmpty)
                  Text(
                    state.chapterTitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AccessGuide',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(state.isConnected
                ? '● Connected to tutorial server'
                : '○ Not connected — run the tutorial server in your IDE'),
            if (state.isConnected) ...[
              const SizedBox(height: 4),
              Text('Chapter ${state.chapterIndex + 1}: ${state.chapterTitle}'),
              Text('Step ${state.stepIndex + 1} of ${state.totalSteps}: ${state.stepTitle}'),
            ],
          ],
        ),
      ),
    );
  }
}
