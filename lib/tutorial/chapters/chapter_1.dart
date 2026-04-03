import '../chapter_model.dart';

/// Chapter 1 — Welcome to AccessBank
///
/// A guided first look at the app, experiencing it as screen-reader users do,
/// spotting obvious issues, and building a mental model of Flutter's semantics
/// tree.
const Chapter chapter1 = Chapter(
  id: 1,
  title: 'Welcome to AccessBank',
  branchName: 'chapter-1-setup',
  description:
      'Take a tour of the AccessBank demo app — first through sighted eyes, '
      'then through a screen reader. You\'ll spot real barriers that block '
      'users from banking independently and get your first look at Flutter\'s '
      'semantics tree, the foundation of everything we\'ll fix.',
  screenFocus: 'All screens',
  estimatedMinutes: 20,
  vibe: 'Oh wow, this is what it\'s like for some users?',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Tour the App',
      explanation:
          'AccessBank has five screens — spend a couple of minutes clicking '
          'through all of them before we bring in the screen reader:\n\n'
          '1. **Login** — email + password fields and a Sign In button\n'
          '2. **Account Overview** — a list of your accounts with balances\n'
          '3. **Transaction List** — recent transactions with filter chips\n'
          '4. **Transfer** — move money between accounts\n'
          '5. **Settings** — profile and notification preferences\n\n'
          'Notice what each screen looks like, what actions you can take, and '
          'what information is shown. You\'ll revisit each screen shortly — '
          'but this time without your eyes.',
    ),
    TutorialStep(
      id: 2,
      title: 'The Screen Reader Experience',
      explanation:
          'Now enable TalkBack or VoiceOver and navigate to the Account '
          'Overview screen using *only* screen reader gestures — no peeking!\n\n'
          'Swipe right to move through elements one by one. Listen carefully '
          'to what is announced. You might hear things like "Image", "Button", '
          'or long cryptic strings instead of meaningful account names.\n\n'
          'This is the daily reality for users who rely on assistive '
          'technology to access their finances.',
      whyItMatters:
          'About 2.2 billion people worldwide have some form of vision '
          'impairment. Even if only a fraction use screen readers, that is '
          'still tens of millions of potential AccessBank customers — and '
          'right now, our app largely shuts them out.',
      tryItPrompt:
          'Navigate to Account Overview with your screen reader. Can you '
          'tell which account has the highest balance?',
    ),
    TutorialStep(
      id: 3,
      title: 'Spotting the Problems',
      explanation:
          'Here are five categories of accessibility issues already present '
          'in AccessBank:\n\n'
          '1. **Missing labels** — icon buttons with no text alternative\n'
          '2. **Meaningless labels** — "Image" or generic widget descriptions\n'
          '3. **Poor tab/focus order** — the screen reader jumps around randomly\n'
          '4. **Low contrast** — light-grey text on white backgrounds\n'
          '5. **Tiny touch targets** — icon buttons under 48×48 dp\n\n'
          'These aren\'t edge-cases. They are the top five issues found in '
          'accessibility audits of real banking apps.',
      whyItMatters:
          'Every one of these issues blocks real users from banking '
          'independently. Fixing them isn\'t just compliance — it is giving '
          'people back their financial autonomy.',
    ),
    TutorialStep(
      id: 4,
      title: 'Understanding the Semantics Tree',
      explanation:
          'Flutter renders your UI to a canvas — pixels, not DOM elements. '
          'To make that canvas understandable to assistive technology, Flutter '
          'maintains a parallel **semantics tree**: a structured description of '
          'every meaningful element on screen (labels, roles, states, actions).\n\n'
          'When you add a `Semantics` widget (or use a widget that adds '
          'semantics automatically, like `ElevatedButton`), Flutter updates '
          'this tree and the OS accessibility service reads it.\n\n'
          'The diff below shows the difference between a card with no '
          'semantics information versus one with a proper label.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/account_card.dart',
        before: '''
// No semantics — TalkBack announces "Image" then "4,285.50"
// as two unrelated elements.
Container(
  child: Row(
    children: [
      Icon(Icons.account_balance),
      Text('\$4,285.50'),
    ],
  ),
)''',
        after: '''
// Semantics wraps the whole card into one meaningful node.
Semantics(
  label: 'Everyday Checking, balance four thousand two hundred '
         'eighty-five dollars and fifty cents',
  child: Container(
    child: Row(
      children: [
        Icon(Icons.account_balance),
        Text('\$4,285.50'),
      ],
    ),
  ),
)''',
      ),
      referenceLinks: [
        'https://api.flutter.dev/flutter/widgets/Semantics-class.html',
      ],
    ),
    TutorialStep(
      id: 5,
      title: 'Exploring SemanticsNodes',
      explanation:
          'Turn on the AccessGuide inspector (magnifying-glass icon) and '
          'look at the Account Overview screen. Each coloured box represents '
          'a `SemanticsNode` — the same data that gets sent to TalkBack or '
          'VoiceOver.\n\n'
          '- **Green border** — the node has a label ✓\n'
          '- **Red border** — an interactive element with no label ✗\n'
          '- **Grey border** — non-interactive, no label (may be fine)\n\n'
          'In the next chapter we will fix every red node on the Account '
          'Overview screen by adding proper `Semantics` widgets.',
      tryItPrompt:
          'Toggle the inspector and count how many elements have labels '
          '(green borders) versus missing labels (red borders).',
    ),
  ],
  quiz: Quiz(
    title: 'Check Your Understanding',
    questions: [
      QuizQuestion(
        question: 'What is Flutter\'s semantics tree?',
        options: [
          'The widget tree rendered to the canvas',
          'A parallel structure that describes the UI to assistive technology',
          'A debug overlay shown in DevTools',
          'The navigation stack of the app',
        ],
        correctIndex: 1,
        explanation:
            'Flutter\'s semantics tree runs alongside the widget tree. '
            'It describes each meaningful element\'s label, role, state, '
            'and actions in a way that OS accessibility services like '
            'TalkBack and VoiceOver can read aloud.',
      ),
      QuizQuestion(
        question: 'Approximately how many people worldwide have some form '
            'of vision impairment?',
        options: [
          '220 million',
          '500 million',
          '2.2 billion',
          '4 billion',
        ],
        correctIndex: 2,
        explanation:
            'According to the World Health Organization, approximately '
            '2.2 billion people have near or distance vision impairment. '
            'This is a huge audience that benefits directly from accessible apps.',
      ),
      QuizQuestion(
        question: 'Which of the following is NOT one of the five common '
            'accessibility issues found in AccessBank?',
        options: [
          'Missing labels on icon buttons',
          'Poor tab/focus order',
          'Too many animations',
          'Low contrast text',
        ],
        correctIndex: 2,
        explanation:
            'The five issues we identified are: missing labels, meaningless '
            'labels, poor tab/focus order, low contrast, and tiny touch '
            'targets. Excessive animation is a separate concern covered '
            'in Chapter 6.',
      ),
    ],
  ),
);
