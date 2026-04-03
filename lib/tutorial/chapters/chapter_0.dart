import '../chapter_model.dart';

/// Chapter 0 — Your Accessibility Toolkit
///
/// Introduces the tools developers use to audit and test accessibility:
/// screen readers, Flutter's semantics debugger, DevTools, and the built-in
/// AccessGuide inspector overlay.
const Chapter chapter0 = Chapter(
  id: 0,
  title: 'Your Accessibility Toolkit',
  branchName: 'chapter-0-toolkit',
  description:
      'Before writing a single line of accessible code you need to know how '
      'to hear what your users hear. In this chapter you will enable a screen '
      'reader, learn the key gestures, and discover the Flutter and in-app '
      'tools that make accessibility testing fast and repeatable.',
  screenFocus: 'Demo',
  estimatedMinutes: 15,
  vibe: 'Now I know how to hear what my users hear',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Enable Your Screen Reader',
      explanation:
          'Every platform ships with a built-in screen reader. On **Android** '
          'it is called **TalkBack** — enable it under Settings > Accessibility '
          '> TalkBack. On **iOS** it is called **VoiceOver** — enable it under '
          'Settings > Accessibility > VoiceOver (or triple-click the side '
          'button if you have set up the Accessibility Shortcut). On **Flutter '
          'Web** you can use the browser\'s built-in screen reader: NVDA or '
          'JAWS on Windows, or VoiceOver in Safari/Chrome on macOS.\n\n'
          'Once enabled, the screen reader takes over all touch and keyboard '
          'input — every tap now *focuses* an element and reads its label aloud '
          'instead of activating it immediately.',
      tryItPrompt: 'Enable your platform\'s screen reader now.',
      referenceLinks: [
        'https://support.google.com/accessibility/android/answer/6007100',
        'https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios',
      ],
    ),
    TutorialStep(
      id: 2,
      title: 'Key Screen Reader Gestures',
      explanation:
          'Screen readers completely change how you interact with a device. '
          'Here are the gestures you will use constantly:\n\n'
          '**Navigate forward/backward** — Swipe right or left to move to the '
          'next or previous accessible element.\n\n'
          '**Activate an element** — Double-tap anywhere on screen to activate '
          'the currently focused element (a button, link, etc.).\n\n'
          '**Explore by touch** — Drag your finger around the screen; the '
          'screen reader reads whatever element is under your fingertip.\n\n'
          '**Scroll** — Use a three-finger swipe up or down.\n\n'
          'On VoiceOver, navigation also works with a Bluetooth keyboard using '
          'Tab / Shift-Tab and Space or Return to activate.',
      whyItMatters:
          'These are the same gestures millions of users rely on daily. '
          'Feeling them first-hand is the fastest way to build empathy for '
          'what happens when a label is missing or a button is too small.',
    ),
    TutorialStep(
      id: 3,
      title: "Flutter's Semantics Debugger",
      explanation:
          'Flutter includes a built-in visual overlay that shows you the '
          'semantics tree — the data structure the OS accessibility services '
          'read. Set `showSemanticsDebugger: true` on your `MaterialApp` and '
          'every widget that has semantics will be outlined and labelled '
          'on screen.\n\n'
          'This is a quick way to spot missing labels or merged/excluded nodes '
          'without turning on a full screen reader.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/main.dart',
        before: '''
MaterialApp(
  title: 'AccessBank',
  theme: theme,
  home: const HomeScreen(),
)''',
        after: '''
MaterialApp(
  title: 'AccessBank',
  theme: theme,
  // Set to true to visualise the semantics tree.
  showSemanticsDebugger: true,
  home: const HomeScreen(),
)''',
      ),
      tryItPrompt:
          'Add showSemanticsDebugger: true and hot-reload. Every outlined '
          'box is a semantics node — tap one to see its label in the console.',
    ),
    TutorialStep(
      id: 4,
      title: 'DevTools Accessibility Inspector',
      explanation:
          'Flutter DevTools ships with a dedicated **Accessibility** tab '
          '(also called the Widget Inspector\'s Semantics pane). Open it with '
          '`flutter pub global activate devtools` then `flutter run` and click '
          'the DevTools URL printed in your terminal.\n\n'
          'The Accessibility tab lets you:\n'
          '- Browse the full semantics tree\n'
          '- See every node\'s label, hint, value, and actions\n'
          '- Highlight the widget that corresponds to each node\n\n'
          'Use it when you want to audit the whole tree rather than tapping '
          'element by element.',
      referenceLinks: [
        'https://docs.flutter.dev/tools/devtools/inspector',
      ],
    ),
    TutorialStep(
      id: 5,
      title: 'The AccessGuide Inspector',
      explanation:
          'This app has a built-in **inspector overlay** you can toggle '
          'without leaving the app. Tap the magnifying-glass icon in the '
          'tutorial panel or call `TutorialController.toggleInspector()` '
          'programmatically.\n\n'
          'When the inspector is on, every semantics node on the demo banking '
          'screen is highlighted with a coloured border and its label is shown '
          'inline — green for labelled nodes, red for unlabelled interactive '
          'elements that need attention.\n\n'
          'It works on device, simulator, and Flutter Web — no extra tooling '
          'required.',
      tryItPrompt:
          'Toggle the inspector on and explore the demo screen. How many '
          'red (unlabelled interactive) nodes can you spot?',
    ),
    TutorialStep(
      id: 6,
      title: 'Practice: Navigate by Ear',
      explanation:
          'Now that you have the tools, put them away and use only your ears. '
          'Enable the screen reader, lock your eyes closed (or look away from '
          'the screen), and attempt to complete a real task in AccessBank.\n\n'
          'Notice what is announced clearly and what leaves you guessing. '
          'That confusion is exactly what we\'ll be fixing together in the '
          'chapters ahead.',
      tryItPrompt:
          'Close your eyes, enable the screen reader, and try to check your '
          'account balance. What was the experience like?',
      whyItMatters:
          'Experiencing the app as a screen reader user — even for 60 seconds '
          '— builds more intuition than any amount of reading about '
          'accessibility theory.',
    ),
  ],
  quiz: Quiz(
    title: 'Check Your Toolkit Knowledge',
    questions: [
      QuizQuestion(
        question: 'Which gesture activates the currently focused element '
            'when using TalkBack or VoiceOver?',
        options: [
          'Single tap',
          'Double tap',
          'Long press',
          'Three-finger swipe',
        ],
        correctIndex: 1,
        explanation:
            'With a screen reader active, a single tap moves focus to an '
            'element and announces it. A double tap activates it (like a '
            'regular single tap without the screen reader).',
      ),
      QuizQuestion(
        question: 'What does `showSemanticsDebugger: true` do in MaterialApp?',
        options: [
          'Enables TalkBack automatically on the device',
          'Draws a visual overlay showing the semantics tree nodes',
          'Logs the semantics tree to the console',
          'Breaks the build so you remember to remove it',
        ],
        correctIndex: 1,
        explanation:
            '`showSemanticsDebugger: true` adds a visual overlay to the app '
            'that outlines and labels every widget that has associated '
            'semantics data — great for a quick visual audit.',
      ),
      QuizQuestion(
        question: 'How do you navigate between elements with a screen reader '
            'on a touchscreen?',
        options: [
          'Tap each element directly',
          'Swipe up and down',
          'Swipe right and left',
          'Use the volume buttons',
        ],
        correctIndex: 2,
        explanation:
            'Swiping right moves focus to the next accessible element; '
            'swiping left moves to the previous one. This is the primary '
            'navigation gesture on both TalkBack (Android) and VoiceOver '
            '(iOS).',
      ),
    ],
  ),
);
