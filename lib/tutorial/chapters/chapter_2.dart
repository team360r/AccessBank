import '../chapter_model.dart';

/// Chapter 2 — Speaking the Language
///
/// Teaches the core Semantics widget API by fixing the Account Overview screen:
/// adding labels, hints, values, merging related nodes, and silencing
/// decorative elements.
const Chapter chapter2 = Chapter(
  id: 2,
  title: 'Speaking the Language',
  branchName: 'chapter-2-semantics',
  description:
      'Labels are the words your app speaks to users who can\'t see it. '
      'In this chapter you\'ll add semantic labels, hints, and values to the '
      'Account Overview screen, merge related elements into single meaningful '
      'nodes, and silence purely decorative widgets — transforming a confusing '
      'screen into one that\'s a pleasure to navigate by ear.',
  screenFocus: 'Account Overview',
  estimatedMinutes: 25,
  vibe: 'That was easier than I thought!',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Adding Semantic Labels',
      explanation:
          'The `Semantics` widget\'s `label` property provides the text that '
          'a screen reader announces when it focuses on the node. For account '
          'cards, a good label combines the account type and balance in natural '
          'spoken language — not the formatted number that appears on screen.\n\n'
          'Notice how the "after" version spells out the dollar amount in words. '
          'Screen readers read "4,285.50" as "four comma two eight five point '
          'five zero" — not what you want!',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// TalkBack: "four two eight five fifty" — confusing!
Card(
  child: Row(
    children: [
      Icon(Icons.account_balance),
      Column(
        children: [
          Text('Everyday Checking'),
          Text('\$4,285.50'),
        ],
      ),
    ],
  ),
)''',
        after: '''
// TalkBack: "Everyday Checking account, balance four thousand
// two hundred eighty-five dollars and fifty cents"
Semantics(
  label: 'Everyday Checking account, '
         'balance four thousand two hundred '
         'eighty-five dollars and fifty cents',
  child: Card(
    child: Row(
      children: [
        Icon(Icons.account_balance),
        Column(
          children: [
            Text('Everyday Checking'),
            Text('\$4,285.50'),
          ],
        ),
      ],
    ),
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Hints and Values',
      explanation:
          'Beyond `label`, the `Semantics` widget gives you two more tools:\n\n'
          '- **`value`** — the current state of an element (e.g. a toggle\'s '
          '"on" or "off", a slider\'s current position).\n'
          '- **`hint`** — extra guidance about what will happen when the user '
          'activates the element ("double tap to view transaction history").\n\n'
          'For the quick-action buttons on the account card, adding a `hint` '
          'makes it clear what each button does rather than just announcing '
          'an icon name.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// TalkBack announces "Button" — useless!
IconButton(
  icon: const Icon(Icons.history),
  onPressed: () => _openTransactions(account),
)''',
        after: '''
Semantics(
  label: 'View transactions',
  hint: 'Opens the transaction history for this account',
  child: IconButton(
    icon: const Icon(Icons.history),
    onPressed: () => _openTransactions(account),
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 3,
      title: 'The Semantics Widget Deep Dive',
      explanation:
          'The `Semantics` widget has over 30 properties — here are the ones '
          'you will reach for most often:\n\n'
          '| Property | Purpose |\n'
          '|---|---|\n'
          '| `label` | What the element *is* |\n'
          '| `hint` | What will happen when activated |\n'
          '| `value` | Current state or value |\n'
          '| `button` | Marks the node as a button role |\n'
          '| `header` | Marks the node as a heading |\n'
          '| `image` | Marks the node as an image |\n'
          '| `liveRegion` | Announces changes automatically |\n'
          '| `onTap` / `onLongPress` | Custom semantic actions |\n'
          '| `enabled` | Whether the element is interactive |\n\n'
          'You don\'t always need to set all of these — Flutter\'s built-in '
          'widgets (ElevatedButton, Checkbox, Slider…) set the role properties '
          'for you automatically.',
      referenceLinks: [
        'https://api.flutter.dev/flutter/widgets/Semantics-class.html',
      ],
    ),
    TutorialStep(
      id: 4,
      title: 'MergeSemantics',
      explanation:
          '`MergeSemantics` combines all descendant semantics nodes into a '
          'single node. This is perfect for compound elements — like an account '
          'card — where you want the screen reader to announce the whole card '
          'as one item rather than visiting the icon, then the name, then the '
          'balance separately.\n\n'
          'After merging, the user hears "Everyday Checking, \$4,285.50, '
          'Savings, \$12,400.00" — one announce per account, not six.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// Screen reader visits: icon → account name → balance → 3 buttons
// = 6 focus stops per account card
Row(
  children: [
    Icon(Icons.account_balance),
    Text('Everyday Checking'),
    Text('\$4,285.50'),
  ],
)''',
        after: '''
// Screen reader visits the whole row as one node
MergeSemantics(
  child: Row(
    children: [
      Icon(Icons.account_balance),
      Text('Everyday Checking'),
      Text('\$4,285.50'),
    ],
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'ExcludeSemantics',
      explanation:
          '`ExcludeSemantics` hides a subtree from the semantics tree entirely. '
          'Use it for purely decorative elements that add visual interest but '
          'no information — background patterns, separator lines, decorative '
          'icon repetitions.\n\n'
          'Without exclusion, a screen reader might announce "Image, Image, '
          'Image" three times for a row of decorative icons — confusing and '
          'noisy.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// TalkBack announces "Image" for the decorative background icon
Stack(
  children: [
    Positioned.fill(
      child: Icon(
        Icons.account_balance_wallet,
        size: 80,
        color: Colors.white12,
      ),
    ),
    content,
  ],
)''',
        after: '''
// Decorative icon is invisible to screen readers
Stack(
  children: [
    Positioned.fill(
      child: ExcludeSemantics(
        child: Icon(
          Icons.account_balance_wallet,
          size: 80,
          color: Colors.white12,
        ),
      ),
    ),
    content,
  ],
)''',
      ),
    ),
    TutorialStep(
      id: 6,
      title: 'Hear the Difference',
      explanation:
          'Now it is time to experience the improvement you have just made. '
          'Use the toggle at the top of the tutorial panel to switch between '
          'the "Before" (original) and "After" (accessible) versions of the '
          'Account Overview screen.\n\n'
          'Enable your screen reader and swipe through both versions. The '
          '"after" version should feel dramatically more coherent — each account '
          'announces as a single meaningful unit and the decorative noise is gone.',
      tryItPrompt:
          'Toggle between accessible and original versions with your screen '
          'reader active. Notice how many fewer swipes you need to understand '
          'the account overview in the "after" version.',
    ),
  ],
  quiz: Quiz(
    title: 'Semantics Quiz',
    questions: [
      QuizQuestion(
        question: 'Which Semantics property provides the text a screen reader '
            'announces when it focuses on a widget?',
        options: ['hint', 'value', 'label', 'tooltip'],
        correctIndex: 2,
        explanation:
            '`label` is the primary text announced when a screen reader '
            'focuses on a node. `hint` provides additional guidance about '
            'what will happen on activation, and `value` describes the '
            'current state.',
      ),
      QuizQuestion(
        question: 'What does the `MergeSemantics` widget do?',
        options: [
          'Removes all semantics from its subtree',
          'Combines all descendant semantics nodes into one node',
          'Copies semantics from a sibling widget',
          'Adds a spoken label to each child widget',
        ],
        correctIndex: 1,
        explanation:
            '`MergeSemantics` merges all descendant semantics nodes into a '
            'single node. This is useful for compound elements like cards '
            'where you want one announcement per item, not one per child widget.',
      ),
      QuizQuestion(
        question: 'When should you use `ExcludeSemantics`?',
        options: [
          'For all images in the app',
          'For any element a user might want to interact with',
          'For purely decorative elements that carry no information',
          'For text that is already announced elsewhere',
        ],
        correctIndex: 2,
        explanation:
            '`ExcludeSemantics` hides a widget subtree from the semantics '
            'tree. It is appropriate for decorative elements — background '
            'patterns, separator lines, repeated decorative icons — that '
            'would create noise without adding information.',
      ),
    ],
  ),
);
