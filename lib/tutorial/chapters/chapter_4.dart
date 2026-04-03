import '../chapter_model.dart';

/// Chapter 4 — See Clearly
///
/// Covers the visual accessibility layer: contrast ratios, text scaling,
/// layouts that survive large text, dark mode done right, and avoiding
/// colour-only communication.
const Chapter chapter4 = Chapter(
  id: 4,
  title: 'See Clearly',
  branchName: 'chapter-4-visual',
  description:
      'Visual accessibility goes far beyond screen readers. In this chapter '
      'you\'ll fix low-contrast text, ensure the UI scales gracefully when '
      'users increase their font size, tune dark mode contrast, and stop '
      'relying on colour alone to communicate meaning — making AccessBank '
      'readable for everyone from users with low vision to those reading in '
      'bright sunlight.',
  screenFocus: 'Account Overview + theme',
  estimatedMinutes: 20,
  vibe: 'My grandma could actually use this now',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Contrast Matters',
      explanation:
          'WCAG 2.1 Success Criterion 1.4.3 requires a **4.5:1** contrast '
          'ratio between text and its background (3:1 for large text, defined '
          'as 18pt normal or 14pt bold). AccessBank\'s original account balance '
          'text uses `Colors.grey[400]` on white — a ratio of roughly 2.9:1, '
          'well below the threshold.\n\n'
          'The fix is straightforward: swap the inaccessible colour for one '
          'that passes. Tools like the Accessible Colors website or the Flutter '
          'DevTools colour picker can check ratios instantly.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// Contrast ratio ~2.9:1 — fails WCAG AA
Text(
  'Balance',
  style: TextStyle(
    color: Colors.grey[400],
    fontSize: 12,
  ),
)''',
        after: '''
// Contrast ratio ~5.9:1 — passes WCAG AA and AAA
Text(
  'Balance',
  style: TextStyle(
    color: Colors.grey[700],
    fontSize: 12,
  ),
)''',
      ),
      whyItMatters:
          '4.5:1 contrast ratio is not just a number — it is the threshold '
          'where most people with moderate vision loss (including many older '
          'adults) can still read text comfortably. One in three people over '
          '65 have some form of vision impairment.',
    ),
    TutorialStep(
      id: 2,
      title: 'Text That Scales',
      explanation:
          'Users in iOS Settings or Android Display Settings can increase the '
          'system font size. Flutter respects this via `MediaQuery.textScalerOf`. '
          'The problem arises when layouts hardcode heights or use '
          '`textScaleFactor: 1.0` to override the user\'s preference.\n\n'
          'Remove any explicit scale overrides and test at 200% font size — '
          'this is the WCAG 1.4.4 success criterion ("Resize text").',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/account_card.dart',
        before: '''
// Bad: ignores the user's accessibility settings
Text(
  accountName,
  textScaleFactor: 1.0, // forces default size
  style: const TextStyle(fontSize: 16),
)''',
        after: '''
// Good: respects the user's font-size preference
Text(
  accountName,
  style: const TextStyle(fontSize: 16),
  // No textScaleFactor — Flutter uses MediaQuery automatically
)''',
      ),
      referenceLinks: [
        'https://www.w3.org/WAI/WCAG21/Understanding/resize-text.html',
      ],
    ),
    TutorialStep(
      id: 3,
      title: "Layouts That Don't Break",
      explanation:
          'Respecting text scale is only half the battle — the layout must '
          'also handle the extra space. Fixed-height containers that worked '
          'at 100% scale will overflow at 200%.\n\n'
          'Replace fixed heights with flexible layouts:\n'
          '- Use `Flexible` or `Expanded` inside `Row`/`Column`\n'
          '- Replace `SizedBox(height: 48)` with `ConstrainedBox(minHeight: 48)`\n'
          '- Let `Card` size itself based on content\n\n'
          'Test by setting `MediaQuery.of(context).textScaler` to a scale '
          'factor of 2.0 in a test, or change the system font size on device.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/account_card.dart',
        before: '''
// Overflows at large text sizes
SizedBox(
  height: 56,
  child: Row(
    children: [
      const Icon(Icons.account_balance),
      Text(accountName),
      const Spacer(),
      Text(balanceText),
    ],
  ),
)''',
        after: '''
// Grows with the text
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 56),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Icon(Icons.account_balance),
      const SizedBox(width: 12),
      Expanded(child: Text(accountName)),
      Text(balanceText),
    ],
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 4,
      title: 'Dark Mode Done Right',
      explanation:
          'The `Colors.grey[700]` we used in the light theme is too light on '
          'dark backgrounds. Each theme variant needs its own contrast-tested '
          'palette.\n\n'
          'Define a separate `ColorScheme.dark()` with accessible equivalents, '
          'or use Material 3\'s dynamic colour system which handles contrast '
          'automatically when you provide a seed colour.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/theme/app_theme.dart',
        before: '''
ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFF9E9E9E), // ~3.8:1 — fails AA
  ),
);''',
        after: '''
ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFD4D4D4), // ~9.2:1 — passes AAA
  ),
);''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'Beyond Color',
      explanation:
          'About 300 million people are colour blind — most commonly with '
          'red-green confusion. If your app uses colour alone to show "this '
          'account is overdrawn" (red) versus "this account is healthy" '
          '(green), colour-blind users miss that information entirely.\n\n'
          'Add a secondary indicator — an icon, a text label, or a pattern — '
          'alongside every colour-coded element.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/balance_indicator.dart',
        before: '''
// Colour alone — invisible to users with red-green colour blindness
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: isPositive ? Colors.green : Colors.red,
    shape: BoxShape.circle,
  ),
)''',
        after: '''
// Colour + icon — works for everyone
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
      color: isPositive ? Colors.green[700] : Colors.red[700],
      size: 14,
      semanticLabel: isPositive ? 'Positive balance' : 'Overdrawn',
    ),
    const SizedBox(width: 4),
    Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isPositive ? Colors.green[700] : Colors.red[700],
        shape: BoxShape.circle,
      ),
    ),
  ],
)''',
      ),
      whyItMatters:
          'About 300 million people are colour blind. Colour alone never '
          'communicates meaning reliably — always pair it with shape, icon, '
          'or text. This is WCAG 1.4.1: "Use of Color".',
    ),
  ],
  quiz: Quiz(
    title: 'Visual Accessibility Quiz',
    questions: [
      QuizQuestion(
        question: 'What is the WCAG AA minimum contrast ratio for normal-sized '
            'body text?',
        options: ['3:1', '4.5:1', '7:1', '2:1'],
        correctIndex: 1,
        explanation:
            'WCAG 2.1 Success Criterion 1.4.3 requires a 4.5:1 contrast '
            'ratio for normal text (under 18pt regular or 14pt bold). '
            'Large text requires a minimum of 3:1.',
      ),
      QuizQuestion(
        question: 'What happens when you set `textScaleFactor: 1.0` on a Text '
            'widget?',
        options: [
          'The text becomes slightly larger',
          'The user\'s system font-size preference is ignored',
          'The text is hidden from screen readers',
          'The text is rendered at the system default size',
        ],
        correctIndex: 1,
        explanation:
            'Setting `textScaleFactor: 1.0` overrides the device\'s system '
            'font-size setting, forcing text to render at the default scale '
            'even when the user has requested larger text for accessibility '
            'reasons. This violates WCAG 1.4.4.',
      ),
      QuizQuestion(
        question: 'Which WCAG criterion requires that information is not '
            'conveyed by colour alone?',
        options: [
          '1.3.1 Info and Relationships',
          '1.4.1 Use of Color',
          '1.4.3 Contrast (Minimum)',
          '2.4.6 Headings and Labels',
        ],
        correctIndex: 1,
        explanation:
            'WCAG 1.4.1 "Use of Color" states that colour must not be the '
            'only visual means of conveying information, indicating an action, '
            'prompting a response, or distinguishing a visual element.',
      ),
    ],
  ),
);
