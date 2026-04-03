import '../chapter_model.dart';

/// Chapter 6 — Motion & Interaction
///
/// Covers motor accessibility: respecting reduced-motion preferences,
/// minimum touch target sizes, alternatives to swipe-only gestures, and
/// long-press alternatives.
const Chapter chapter6 = Chapter(
  id: 6,
  title: 'Motion & Interaction',
  branchName: 'chapter-6-motion',
  description:
      'Not every user can flick, swipe, or tap a tiny icon. In this chapter '
      'you\'ll respect system-wide motion preferences to avoid triggering '
      'vestibular disorders, enforce 48×48 dp minimum touch targets, and '
      'provide button alternatives to every swipe-based gesture so that '
      'motor-impaired users can perform every action in the app.',
  screenFocus: 'Transaction List',
  estimatedMinutes: 20,
  vibe: 'Not everyone can swipe precisely',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Respect Motion Preferences',
      explanation:
          'Users with vestibular disorders can experience nausea, dizziness, '
          'or worse from excessive screen animation. Both iOS and Android '
          'provide a "Reduce Motion" setting that apps are expected to honour.\n\n'
          'In Flutter, check `MediaQuery.disableAnimationsOf(context)` (or '
          '`MediaQuery.of(context).disableAnimations`) and reduce or eliminate '
          'animations when it returns `true`.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
// Always animates — can trigger vestibular issues
AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  child: _buildFilteredList(selectedFilter),
)''',
        after: '''
// Skips animation when the user prefers reduced motion
Builder(
  builder: (context) {
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 400),
      child: _buildFilteredList(selectedFilter),
    );
  },
)''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Touch Target Sizing',
      explanation:
          'Apple\'s Human Interface Guidelines and Google\'s Material Design '
          'both require a minimum **44pt / 48dp** touch target for interactive '
          'elements. The Transaction List uses 24dp icon buttons which are '
          'half the required size — difficult for users with tremors or '
          'limited dexterity.\n\n'
          'Wrap small icons in `SizedBox` or use `IconButton` with '
          '`constraints: BoxConstraints(minWidth: 48, minHeight: 48)` to '
          'expand the tappable area without changing the visual size.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
// 24dp touch target — too small!
GestureDetector(
  onTap: () => _openDetails(transaction),
  child: const Icon(Icons.chevron_right, size: 24),
)''',
        after: '''
// 48dp touch target — meets guidelines
IconButton(
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  icon: const Icon(Icons.chevron_right, size: 24),
  tooltip: 'View transaction details',
  onPressed: () => _openDetails(transaction),
)''',
      ),
      whyItMatters:
          'Small touch targets are one of the most common mobile '
          'accessibility failures. For users with Parkinson\'s, arthritis, '
          'or essential tremor, a 24dp button is essentially unusable. '
          'The 48dp minimum is the point where most users can tap reliably.',
    ),
    TutorialStep(
      id: 3,
      title: 'Swipe Alternatives',
      explanation:
          'The `Dismissible` widget lets sighted users swipe to delete a '
          'transaction — a great gesture shortcut, but inaccessible for:\n\n'
          '- Screen reader users (no swipe-to-delete action is announced)\n'
          '- Switch Access / Switch Control users\n'
          '- Users who cannot perform the precise left-swipe gesture\n\n'
          'Add an explicit "Delete" button inside the tile as the primary '
          'accessible action. The swipe gesture can remain as a shortcut, '
          'but must not be the *only* way to delete.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
// Swipe-only delete — inaccessible
Dismissible(
  key: Key(transaction.id),
  direction: DismissDirection.endToStart,
  onDismissed: (_) => _deleteTransaction(transaction),
  child: TransactionTile(transaction: transaction),
)''',
        after: '''
// Swipe still works AND there is an accessible button alternative
Dismissible(
  key: Key(transaction.id),
  direction: DismissDirection.endToStart,
  background: const DeleteBackground(),
  onDismissed: (_) => _deleteTransaction(transaction),
  child: TransactionTile(
    transaction: transaction,
    trailing: Semantics(
      label: 'Delete transaction',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(transaction),
      ),
    ),
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 4,
      title: 'Long-Press Alternatives',
      explanation:
          'Long-press actions are invisible to screen reader users, keyboard '
          'users, and anyone who cannot hold their finger steady on the screen '
          'for the required duration.\n\n'
          'Add a context menu — either a `PopupMenuButton` or a visible '
          '"More options" button — that exposes the same actions available '
          'via long press.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
// Long press only — inaccessible
GestureDetector(
  onLongPress: () => _showTransactionMenu(transaction),
  child: TransactionTile(transaction: transaction),
)''',
        after: '''
// Long press still works AND there is an accessible menu button
GestureDetector(
  onLongPress: () => _showTransactionMenu(transaction),
  child: TransactionTile(
    transaction: transaction,
    trailing: PopupMenuButton<String>(
      tooltip: 'More options for this transaction',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => _handleAction(action, transaction),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'copy', child: Text('Copy reference')),
        PopupMenuItem(value: 'report', child: Text('Report an issue')),
      ],
    ),
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'Motor Accessibility Testing',
      explanation:
          'The most thorough way to test motor accessibility is to use '
          'Switch Access (Android) or Switch Control (iOS) — assistive '
          'technology designed for users who can operate only one or two '
          'switches.\n\n'
          'On **Android**: Settings > Accessibility > Switch Access. '
          'Configure your volume button as a switch.\n\n'
          'On **iOS**: Settings > Accessibility > Switch Control. '
          'Configure a switch and use the scanning mode.\n\n'
          'Try to complete a real task: delete a transaction you didn\'t '
          'authorise. If you can\'t, fix the interface before moving on.',
      tryItPrompt:
          'Enable Switch Access (Android) or Switch Control (iOS) and try '
          'to delete a transaction. If it is not reachable with a single '
          'switch, come back and add the button alternative from Step 3.',
    ),
  ],
  quiz: Quiz(
    title: 'Motion & Interaction Quiz',
    questions: [
      QuizQuestion(
        question: 'Which Flutter API do you use to check whether the user has '
            'enabled "Reduce Motion" on their device?',
        options: [
          'MediaQuery.accessibilityFeaturesOf(context).reduceMotion',
          'MediaQuery.disableAnimationsOf(context)',
          'Theme.of(context).animationTheme.reduceMotion',
          'WidgetsBinding.instance.window.semanticsEnabled',
        ],
        correctIndex: 1,
        explanation:
            '`MediaQuery.disableAnimationsOf(context)` returns `true` when '
            'the user has enabled Reduce Motion (iOS) or Remove animations '
            '(Android). Respond by setting animation durations to zero.',
      ),
      QuizQuestion(
        question: 'What is the recommended minimum touch target size according '
            'to Material Design and Apple\'s HIG?',
        options: ['24×24 dp', '36×36 dp', '48×48 dp', '56×56 dp'],
        correctIndex: 2,
        explanation:
            'Both Material Design (48×48 dp) and Apple HIG (44×44 pt) '
            'specify this as the minimum for reliable interaction. Smaller '
            'targets are frequently missed by users with motor impairments '
            'or those using the device while in motion.',
      ),
      QuizQuestion(
        question: 'If a feature is only accessible via a long press gesture, '
            'which users are excluded?',
        options: [
          'Only users with very large fingers',
          'Screen reader users, keyboard users, and switch-control users',
          'Users on Android (long press is iOS-only)',
          'Nobody — all users can long-press',
        ],
        correctIndex: 1,
        explanation:
            'Long press gestures are not announced or accessible to screen '
            'reader users, keyboard users, or switch-control users. Any '
            'action only reachable via long press must also have an '
            'equivalent button or menu option.',
      ),
    ],
  ),
);
