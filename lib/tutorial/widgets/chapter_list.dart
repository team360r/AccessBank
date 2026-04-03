import 'package:flutter/material.dart';

import '../tutorial_controller.dart';

/// Scrollable list of all chapters in the tutorial.
///
/// Each row shows the chapter's lock/complete/play status, title, description,
/// and estimated time. Tapping a row calls [controller.goToChapter].
class ChapterList extends StatelessWidget {
  const ChapterList({super.key, required this.controller});

  final TutorialController controller;

  @override
  Widget build(BuildContext context) {
    final chapters = controller.chapters;
    if (chapters.isEmpty) {
      return const Center(
        child: Text('No chapters available yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: chapters.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isCurrent = index == controller.currentChapterIndex;
        final isCompleted = controller.chapterCompleted[chapter.id] == true;
        final isUnlocked = controller.isChapterUnlocked(index);

        IconData statusIcon;
        Color statusColor;

        if (!isUnlocked) {
          statusIcon = Icons.lock_outline;
          statusColor = Colors.grey;
        } else if (isCompleted) {
          statusIcon = Icons.check_circle_outline;
          statusColor = Colors.green.shade700;
        } else if (isCurrent) {
          statusIcon = Icons.play_circle_outline;
          statusColor = Theme.of(context).colorScheme.primary;
        } else {
          statusIcon = Icons.radio_button_unchecked;
          statusColor = Colors.grey;
        }

        return ListTile(
          leading: Icon(statusIcon, color: statusColor),
          title: Text(
            chapter.title,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${chapter.estimatedMinutes} min',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chapter.screenFocus,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          enabled: isUnlocked,
          selected: isCurrent,
          selectedTileColor:
              Theme.of(context).colorScheme.primary.withAlpha(20),
          onTap: isUnlocked
              ? () => controller.goToChapter(index)
              : null,
        );
      },
    );
  }
}
