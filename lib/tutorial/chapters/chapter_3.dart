import '../chapter_model.dart';

/// Chapter 3 — Finding Your Way
///
/// Covers keyboard and screen-reader navigation order: fixing tab order on
/// the login form, handling focus traps in dialogs, and adding skip-navigation
/// shortcuts.
const Chapter chapter3 = Chapter(
  id: 3,
  title: 'Finding Your Way',
  branchName: 'chapter-3-navigation',
  description:
      'Broken focus order is one of the most disorienting accessibility '
      'failures — imagine trying to fill in a form while focus jumps '
      'unpredictably. In this chapter you\'ll fix the login screen\'s tab '
      'order, trap focus correctly inside modal dialogs, and add skip '
      'navigation so keyboard users aren\'t forced to tab through the '
      'entire header on every screen.',
  screenFocus: 'Login + dialogs',
  estimatedMinutes: 20,
  vibe: 'I never thought about Tab order before',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Fix the Tab Order',
      explanation:
          'By default, Flutter traverses widgets in the order they appear in '
          'the widget tree, which usually corresponds to paint order. On the '
          'Login screen the floating action button was placed early in the tree '
          'for z-order reasons — so the screen reader visits it *before* the '
          'email field, which is deeply confusing.\n\n'
          '`FocusTraversalGroup` lets you define an independent traversal group '
          'so that widgets inside it are ordered separately from the rest of '
          'the screen.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
// Focus jumps: FAB → Email → Password → Sign In
// because of widget tree ordering
Scaffold(
  body: LoginForm(),
  floatingActionButton: HelpFab(),
)''',
        after: '''
// Focus stays within LoginForm before reaching the FAB
Scaffold(
  body: FocusTraversalGroup(
    policy: ReadingOrderTraversalPolicy(),
    child: LoginForm(),
  ),
  floatingActionButton: HelpFab(),
)''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Custom Traversal Order',
      explanation:
          '`FocusTraversalOrder` with an `OrderedTraversalPolicy` lets you '
          'set an explicit numeric order on individual widgets. This is the '
          'sledgehammer when the default reading-order policy still gets it '
          'wrong — use it sparingly, but it is invaluable when layouts are '
          'designed in a non-linear visual flow.\n\n'
          'The login form should flow: Email → Password → Sign In. That\'s '
          'exactly what the numbers enforce.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
Column(
  children: [
    EmailField(),
    PasswordField(),
    ForgotPasswordLink(),
    SignInButton(),
  ],
)''',
        after: '''
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: EmailField(),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2),
        child: PasswordField(),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(4),
        child: ForgotPasswordLink(),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(3),
        child: SignInButton(),
      ),
    ],
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 3,
      title: 'Focus Traps',
      explanation:
          'When a modal dialog or bottom sheet opens, focus must stay '
          'inside it until the user dismisses it — otherwise a keyboard '
          'user can Tab behind the dialog and interact with blocked UI.\n\n'
          'Flutter\'s `Dialog` widget automatically requests focus when it '
          'opens, but you still need to wrap the content in a '
          '`FocusTraversalGroup` so that Tab cycles within the dialog and '
          'does not escape.\n\n'
          'Setting `autofocus: true` on the first interactive element ensures '
          'the user lands in the right place immediately.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/confirm_transfer_dialog.dart',
        before: '''
// Focus can leak to background when user presses Tab
AlertDialog(
  title: const Text('Confirm Transfer'),
  content: TransferSummary(),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: _confirmTransfer,
      child: const Text('Confirm'),
    ),
  ],
)''',
        after: '''
// Focus is trapped within the dialog
AlertDialog(
  title: const Text('Confirm Transfer'),
  content: FocusTraversalGroup(
    child: TransferSummary(),
  ),
  actions: [
    TextButton(
      autofocus: true,
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: _confirmTransfer,
      child: const Text('Confirm'),
    ),
  ],
)''',
      ),
      whyItMatters:
          'Without focus management, keyboard users get lost behind dialogs '
          'and may unknowingly trigger actions on the obscured screen. '
          'Proper focus trapping is a WCAG 2.1 Level A requirement.',
    ),
    TutorialStep(
      id: 4,
      title: 'Skip Navigation',
      explanation:
          'When every screen starts with a navigation bar containing six '
          'tabs, a keyboard user must press Tab six times before reaching '
          'the main content — on every single screen. Skip links let users '
          'jump straight to the main content region.\n\n'
          'In Flutter you implement this with a `Focus` node that jumps '
          'programmatically to the first element of the main content area '
          'when the user activates the skip link.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/app_scaffold.dart',
        before: '''
Scaffold(
  appBar: MainAppBar(),
  bottomNavigationBar: MainNavBar(),
  body: content,
)''',
        after: '''
Scaffold(
  appBar: MainAppBar(),
  bottomNavigationBar: MainNavBar(),
  body: Column(
    children: [
      // Skip link — visible only on keyboard focus
      Semantics(
        label: 'Skip to main content',
        child: Focus(
          onFocusChange: (focused) {
            if (focused) setState(() => _skipVisible = true);
            else setState(() => _skipVisible = false);
          },
          child: GestureDetector(
            onTap: () => _mainContentFocus.requestFocus(),
            child: _skipVisible
                ? const SkipBanner()
                : const SizedBox.shrink(),
          ),
        ),
      ),
      Expanded(
        child: Focus(
          focusNode: _mainContentFocus,
          skipTraversal: true,
          child: content,
        ),
      ),
    ],
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'Keyboard-Only Testing',
      explanation:
          'The ultimate validation of your focus order work is to navigate '
          'the entire app without touching the screen — using only a keyboard '
          '(physical or on-screen).\n\n'
          'On **Android** you can connect a Bluetooth keyboard or enable '
          'Switch Access in Accessibility settings. On **iOS** use an '
          'external keyboard with VoiceOver. On **Flutter Web** any keyboard '
          'works — use Tab, Shift-Tab, Enter, and Space.\n\n'
          'Watch for: elements you can\'t reach, buttons that don\'t respond '
          'to Enter/Space, and focus that disappears after a dialog closes.',
      tryItPrompt:
          'Plug in a keyboard (or enable switch access) and navigate the '
          'entire login flow without touching the screen. Can you get all '
          'the way to the Account Overview?',
    ),
  ],
  quiz: Quiz(
    title: 'Navigation & Focus Quiz',
    questions: [
      QuizQuestion(
        question: 'What widget do you use to define an independent focus '
            'traversal group in Flutter?',
        options: [
          'FocusScope',
          'FocusTraversalGroup',
          'Focus',
          'FocusNode',
        ],
        correctIndex: 1,
        explanation:
            '`FocusTraversalGroup` defines a region with its own traversal '
            'policy. Widgets inside the group are ordered relative to each '
            'other, independently of widgets outside the group.',
      ),
      QuizQuestion(
        question: 'Why is a focus trap important in modal dialogs?',
        options: [
          'To prevent the user from closing the dialog accidentally',
          'To stop keyboard users from interacting with content behind the dialog',
          'To improve animation performance',
          'To ensure the dialog is announced by the screen reader',
        ],
        correctIndex: 1,
        explanation:
            'Without a focus trap, keyboard users can Tab past the dialog '
            'boundary and interact with (or accidentally trigger) elements '
            'in the obscured background. Trapping focus keeps interaction '
            'within the dialog until it is dismissed.',
      ),
      QuizQuestion(
        question: 'What is the purpose of a skip navigation link?',
        options: [
          'To hide the navigation bar from sighted users',
          'To let keyboard users jump past repetitive navigation to main content',
          'To disable keyboard navigation on secondary screens',
          'To announce the current page name when the screen loads',
        ],
        correctIndex: 1,
        explanation:
            'Skip links let keyboard and switch-control users bypass '
            'repeated navigation elements (like app bars and tab bars) '
            'that would otherwise require many Tab presses on every screen.',
      ),
    ],
  ),
);
