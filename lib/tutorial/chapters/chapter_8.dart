import '../chapter_model.dart';

/// Chapter 8 — Testing Your Work
///
/// Covers automated semantics testing with widget tests, the matchesSemantics
/// matcher, manual testing checklists, the built-in inspector, integration
/// tests, and CI integration.
const Chapter chapter8 = Chapter(
  id: 8,
  title: 'Testing Your Work',
  branchName: 'chapter-8-testing',
  description:
      'Accessibility improvements only stay fixed if you test them. In this '
      'chapter you\'ll write widget tests that assert on the semantics tree, '
      'use the `matchesSemantics` matcher, build a manual testing checklist, '
      'add accessibility assertions to integration tests, and wire it all '
      'into CI so regressions are caught automatically.',
  screenFocus: 'All screens',
  estimatedMinutes: 25,
  vibe: 'I can prove this works, not just hope',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Widget Tests with Semantics',
      explanation:
          'Flutter widget tests can inspect the live semantics tree using '
          '`SemanticsController`, accessible via `tester.semantics`. '
          'First enable semantics in the test, then use the controller to '
          'find nodes by label, check properties, and assert actions.\n\n'
          'Always call `semantics.dispose()` at the end of the test '
          'to clean up the semantics system.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'test/account_card_test.dart',
        before: '''
testWidgets('account card shows balance', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: AccountCard(account: testAccount)),
  );
  expect(find.text('\$4,285.50'), findsOneWidget);
});''',
        after: '''
testWidgets('account card has accessible label', (tester) async {
  final semantics = tester.ensureSemantics();

  await tester.pumpWidget(
    const MaterialApp(home: AccountCard(account: testAccount)),
  );

  expect(
    tester.getSemantics(find.byType(AccountCard)),
    matchesSemantics(
      label: 'Everyday Checking account, '
             'balance four thousand two hundred '
             'eighty-five dollars and fifty cents',
    ),
  );

  semantics.dispose();
});''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Matching Semantics',
      explanation:
          '`matchesSemantics` is a rich matcher that lets you assert on '
          'many properties of a `SemanticsNode` in one call:\n\n'
          '- `label` / `hint` / `value` — text content\n'
          '- `isButton` / `isHeader` / `isImage` — role flags\n'
          '- `isEnabled` / `isFocused` / `isChecked` — state flags\n'
          '- `actions` — list of `SemanticsAction`s the node supports\n\n'
          'Use it to write precise, readable assertions that will catch '
          'regressions immediately.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'test/transaction_tile_test.dart',
        before: '''
// Vague — only checks visual content
expect(find.text('Delete'), findsOneWidget);''',
        after: '''
// Precise — checks semantic role, label, and available actions
expect(
  tester.getSemantics(find.byTooltip('Delete transaction')),
  matchesSemantics(
    label: 'Delete transaction',
    isButton: true,
    isEnabled: true,
    hasTapAction: true,
  ),
);''',
      ),
      referenceLinks: [
        'https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html',
        'https://docs.flutter.dev/testing/accessibility',
      ],
    ),
    TutorialStep(
      id: 3,
      title: 'Manual Testing Checklist',
      explanation:
          'Automated tests catch missing labels, but only manual testing '
          'catches confusing or misleading ones. Run this checklist on '
          'each screen before calling it done:\n\n'
          '**TalkBack / VoiceOver checklist**\n'
          '- [ ] Every interactive element announces its purpose\n'
          '- [ ] Focus order is logical (left-to-right, top-to-bottom)\n'
          '- [ ] No unlabelled interactive elements (red nodes in inspector)\n'
          '- [ ] Decorative images are hidden from the tree\n'
          '- [ ] Form errors are announced when they appear\n'
          '- [ ] Dialogs trap focus until dismissed\n'
          '- [ ] Route changes are announced\n'
          '- [ ] Loading states are announced\n\n'
          'Test on a real device — simulators sometimes behave differently '
          'from physical hardware for accessibility features.',
      whyItMatters:
          'Automated tests catch missing labels, but only manual testing '
          'catches confusing experiences. An element can have a label and '
          'still describe the wrong thing — only a human ear catches that.',
    ),
    TutorialStep(
      id: 4,
      title: 'The Inspector in Action',
      explanation:
          'The AccessGuide inspector overlay is not just for exploration — '
          'it is a structured audit tool. Work through the Transfer screen '
          'systematically:\n\n'
          '1. Toggle the inspector on\n'
          '2. Count red-bordered nodes (unlabelled interactive elements)\n'
          '3. Tap each to see the full label in the panel\n'
          '4. Toggle between "Before" and "After" to confirm fixes\n\n'
          'The inspector catches issues that `showSemanticsDebugger` misses '
          'because it specifically flags interactive elements with no label '
          '— the most impactful category of accessibility failure.',
      tryItPrompt:
          'Use the inspector to audit the Transfer screen. How many red '
          'nodes do you find? Toggle to the "After" version and check again.',
    ),
    TutorialStep(
      id: 5,
      title: 'Integration Tests',
      explanation:
          'Integration tests run on a real device or emulator, making them '
          'ideal for end-to-end accessibility checks. Use `flutter_test` with '
          '`IntegrationTestWidgetsFlutterBinding` and the same '
          '`tester.ensureSemantics()` + `matchesSemantics` API.\n\n'
          'Integration tests can also drive the app through complete user '
          'journeys and assert on semantics at each step.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'integration_test/login_accessibility_test.dart',
        before: '''
// No accessibility assertions
testWidgets('user can log in', (tester) async {
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'user@test.com');
  await tester.enterText(find.byType(TextField).last, 'password');
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  expect(find.text('Account Overview'), findsOneWidget);
});''',
        after: '''
testWidgets('login screen is accessible', (tester) async {
  final semantics = tester.ensureSemantics();
  await tester.pumpAndSettle();

  // Email field has correct label
  expect(
    tester.getSemantics(find.byKey(const Key('emailField'))),
    matchesSemantics(label: 'Email address'),
  );

  // Sign In button is reachable and labelled
  expect(
    tester.getSemantics(find.byKey(const Key('signInButton'))),
    matchesSemantics(label: 'Sign In', isButton: true),
  );

  semantics.dispose();
});''',
      ),
    ),
    TutorialStep(
      id: 6,
      title: 'CI Integration',
      explanation:
          'Run accessibility tests on every pull request so regressions '
          'are caught before merging. Add a dedicated test step to your CI '
          'pipeline that runs the integration tests on a headless emulator.\n\n'
          'The script below runs all tests tagged `accessibility` so you '
          'can keep fast unit tests and slower accessibility tests separate.',
      codeDiff: CodeDiff(
        language: 'yaml',
        filePath: '.github/workflows/accessibility.yml',
        before: '''
# No accessibility step in CI
- name: Run tests
  run: flutter test''',
        after: '''
# Dedicated accessibility test step
- name: Run widget accessibility tests
  run: flutter test --tags accessibility

- name: Run integration accessibility tests
  run: |
    flutter emulator --launch flutter_emulator
    flutter drive \\
      --driver=test_driver/integration_test.dart \\
      --target=integration_test/login_accessibility_test.dart''',
      ),
    ),
  ],
  quiz: Quiz(
    title: 'Testing Accessibility Quiz',
    questions: [
      QuizQuestion(
        question: 'What does `tester.ensureSemantics()` do in a Flutter widget test?',
        options: [
          'Enables TalkBack in the test environment',
          'Activates the semantics system and returns a handle for cleanup',
          'Asserts that all widgets have semantic labels',
          'Generates a semantics audit report',
        ],
        correctIndex: 1,
        explanation:
            '`tester.ensureSemantics()` activates Flutter\'s semantics '
            'system for the duration of the test and returns a '
            '`SemanticsHandle`. Call `.dispose()` at the end of the test '
            'to clean up. Without it, semantics are not built and '
            '`getSemantics` will fail.',
      ),
      QuizQuestion(
        question: 'What is the key advantage of the `matchesSemantics` matcher '
            'over checking widget text with `find.text()`?',
        options: [
          'matchesSemantics is faster',
          'matchesSemantics checks accessibility roles, states, and actions '
              '— not just visible text',
          'find.text() is deprecated',
          'matchesSemantics works on all Flutter versions',
        ],
        correctIndex: 1,
        explanation:
            '`find.text()` only checks visible text content. '
            '`matchesSemantics` checks the full semantic node including '
            'role (`isButton`), state (`isEnabled`, `isChecked`), available '
            'actions (`hasTapAction`), and semantic label — giving you much '
            'more thorough accessibility coverage.',
      ),
      QuizQuestion(
        question: 'Why should you run accessibility tests in CI?',
        options: [
          'CI environments have better screen readers than local machines',
          'So regressions are caught automatically before merging',
          'Flutter accessibility tests only work in CI',
          'To generate WCAG compliance certificates',
        ],
        correctIndex: 1,
        explanation:
            'Manual audits are valuable but not enough — developers forget, '
            'reviewers miss details, and fixes get accidentally reverted. '
            'Running accessibility tests in CI makes them a required part '
            'of the development workflow, so regressions are caught '
            'automatically on every pull request.',
      ),
    ],
  ),
);
