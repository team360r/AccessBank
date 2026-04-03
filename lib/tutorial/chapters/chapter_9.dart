import '../chapter_model.dart';

/// Chapter 9 — The Polished App
///
/// Full-app audit, platform differences, custom semantics actions, keeping
/// the semantics tree lean, curated learning resources, and a celebration
/// of everything learned.
const Chapter chapter9 = Chapter(
  id: 9,
  title: 'The Polished App',
  branchName: 'chapter-9-polish',
  description:
      'This is the final chapter — and the beginning of a habit. You\'ll '
      'walk through every screen with a screen reader, learn the platform '
      'quirks that trip up even experienced developers, add custom semantics '
      'actions for complex interactions, and discover resources to carry '
      'this work forward. By the end, AccessBank is genuinely usable by '
      'everyone.',
  screenFocus: 'All screens',
  estimatedMinutes: 25,
  vibe: 'I actually understand accessibility now',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Full Audit',
      explanation:
          'Before you can call the app accessible, you need to walk through '
          'the complete user journey end-to-end with a screen reader — not '
          'just individual screens in isolation.\n\n'
          'The full banking workflow:\n'
          '1. Log in with email and password\n'
          '2. Check the balance on your Everyday Checking account\n'
          '3. Transfer \$50 to Savings\n'
          '4. View the transaction history and confirm the transfer appears\n'
          '5. Check Settings to find the notification preference toggle\n\n'
          'Every step should be completable using only swipe-right and '
          'double-tap. If you get stuck anywhere, that is a bug to fix.',
      tryItPrompt:
          'Complete the full banking workflow: log in, check your balance, '
          'make a transfer, view the history, find the notifications toggle. '
          'Time yourself — how long does it take with the screen reader?',
    ),
    TutorialStep(
      id: 2,
      title: 'Platform Differences',
      explanation:
          'Each platform\'s screen reader has its own quirks — things that '
          'work perfectly on Android may behave differently on iOS or web.\n\n'
          '**TalkBack (Android)**\n'
          '- Uses "explore by touch" by default; swipe navigation is opt-in\n'
          '- Long-swipe gestures can be configured by the user\n'
          '- `liveRegion: true` is well supported\n\n'
          '**VoiceOver (iOS)**\n'
          '- Triple-click the side button to toggle — great for testing\n'
          '- `hint` text is read after a brief pause, or on demand via '
          'a rotor gesture\n'
          '- Announcements from `SemanticsService` are sometimes delayed\n\n'
          '**Flutter Web (Chrome + NVDA / JAWS / VoiceOver)**\n'
          '- Semantics are exposed as ARIA attributes — check DevTools '
          'Accessibility pane\n'
          '- Route announcements are less reliable; use `SemanticsService` '
          'explicitly\n'
          '- Keyboard navigation with Tab/Shift-Tab is the primary modality',
      whyItMatters:
          'Each platform has quirks. Test on all three — Android, iOS, and '
          'Flutter Web — before shipping. An issue invisible on one platform '
          'may be a showstopper on another.',
    ),
    TutorialStep(
      id: 3,
      title: 'Custom Semantics Actions',
      explanation:
          'Beyond the standard tap and long-press, `SemanticsAction` lets '
          'you expose custom actions that screen readers can trigger via '
          'their action menu (VoiceOver Rotor, TalkBack local context menu).\n\n'
          'This is perfect for features like "mark transaction as reviewed" '
          'or "copy account number" — actions that have no obvious button '
          'in the visual layout.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/widgets/transaction_tile.dart',
        before: '''
// Only tap and long-press available
GestureDetector(
  onTap: () => _openDetails(transaction),
  onLongPress: () => _showMenu(transaction),
  child: TransactionTileContent(transaction: transaction),
)''',
        after: '''
// Custom actions appear in the screen reader action menu
Semantics(
  label: '\${transaction.description}, '
         '\${transaction.formattedAmount}',
  customSemanticsActions: {
    const CustomSemanticsAction(label: 'Copy reference number'):
        () => _copyReference(transaction),
    const CustomSemanticsAction(label: 'Report an issue'):
        () => _reportIssue(transaction),
  },
  child: GestureDetector(
    onTap: () => _openDetails(transaction),
    child: TransactionTileContent(transaction: transaction),
  ),
)''',
      ),
    ),
    TutorialStep(
      id: 4,
      title: 'Performance',
      explanation:
          'A large semantics tree has a performance cost — Flutter must '
          'diff and sync it on every frame that changes. Keep the tree lean '
          'by removing unnecessary nesting:\n\n'
          '- Use `ExcludeSemantics` on decorative subtrees\n'
          '- Use `MergeSemantics` to collapse related nodes\n'
          '- Avoid wrapping every `Text` in its own `Semantics` widget when '
          '`MergeSemantics` on the parent achieves the same result\n'
          '- Profile with `showSemanticsDebugger` — if you see more nodes '
          'than you expect, look for unnecessary wrappers',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// 5 separate semantics nodes for one account row
Semantics(
  child: Row(
    children: [
      Semantics(child: Icon(Icons.account_balance)),
      Semantics(child: Text(account.name)),
      Semantics(child: Text(account.formattedBalance)),
      Semantics(child: Icon(Icons.chevron_right)),
    ],
  ),
)''',
        after: '''
// 1 merged semantics node for the whole account row
MergeSemantics(
  child: Row(
    children: [
      ExcludeSemantics(child: Icon(Icons.account_balance)),
      Text(account.name),
      Text(account.formattedBalance),
      ExcludeSemantics(child: Icon(Icons.chevron_right)),
    ],
  ),
)''',
      ),
      referenceLinks: [
        'https://docs.flutter.dev/perf/rendering-performance',
      ],
    ),
    TutorialStep(
      id: 5,
      title: 'Resources for the Journey',
      explanation:
          'Accessibility is not a destination — it is a continuous practice. '
          'Here are the resources that will serve you best as you go deeper:\n\n'
          '**Flutter-specific**\n'
          '- Flutter Accessibility docs: comprehensive API coverage\n'
          '- Flutter DevTools Inspector: in-app auditing\n\n'
          '**Standards**\n'
          '- WCAG 2.1: the web/app accessibility standard, Level AA is the '
          'legal baseline in most jurisdictions\n'
          '- W3C Mobile Accessibility Guidelines: mobile-specific patterns\n\n'
          '**Testing tools**\n'
          '- Google Accessibility Scanner (Android)\n'
          '- Xcode Accessibility Inspector (iOS/macOS)\n'
          '- Colour Contrast Analyser (desktop app)\n\n'
          'Keep learning, keep testing, keep shipping accessible software.',
      referenceLinks: [
        'https://docs.flutter.dev/accessibility',
        'https://www.w3.org/TR/WCAG21/',
        'https://www.w3.org/TR/mobile-accessibility-mapping/',
        'https://developer.android.com/guide/topics/ui/accessibility',
        'https://developer.apple.com/accessibility/',
      ],
    ),
    TutorialStep(
      id: 6,
      title: 'Celebration!',
      explanation:
          'You did it!\n\n'
          'Look back at Chapter 1 — the app that announced "Image", "Button", '
          'and random numbers. Now look at what you have built: a banking app '
          'where every account announces its name and balance clearly, forms '
          'guide users through errors, focus moves logically through every '
          'screen, and the whole experience works equally well on Android, '
          'iOS, and the web.\n\n'
          'Here is what you learned:\n'
          '- **Chapter 0** — The tools: TalkBack, VoiceOver, semantics debugger\n'
          '- **Chapter 1** — The problem: how the inaccessible app felt\n'
          '- **Chapter 2** — Semantics: labels, hints, values, merge, exclude\n'
          '- **Chapter 3** — Navigation: tab order, focus traps, skip links\n'
          '- **Chapter 4** — Visual: contrast, text scaling, colour blindness\n'
          '- **Chapter 5** — Forms: labels, error announcements, smart inputs\n'
          '- **Chapter 6** — Motion: reduced motion, touch targets, alternatives\n'
          '- **Chapter 7** — Live regions: announcements, loading, routes\n'
          '- **Chapter 8** — Testing: widget tests, CI, manual checklists\n'
          '- **Chapter 9** — Polish: full audit, platform quirks, custom actions\n\n'
          'That is a complete accessibility toolkit. Now go use it.',
      whyItMatters:
          'You have made this app usable for millions more people. A person '
          'with a vision impairment can now check their balance independently. '
          'A person with a motor impairment can now make a transfer without '
          'help. An older user with reduced contrast sensitivity can now read '
          'every number clearly. That is not just good engineering — it is the '
          'right thing to do.',
    ),
  ],
  quiz: Quiz(
    title: 'Final Assessment',
    questions: [
      QuizQuestion(
        question: 'You discover that a button works perfectly with TalkBack '
            'on Android but is not focusable with VoiceOver on iOS. '
            'What is the most likely cause?',
        options: [
          'The button is using the wrong widget type',
          'A platform-specific behaviour difference — possibly a missing '
              'semantic role or an interaction that works differently '
              'on each platform',
          'TalkBack is more advanced than VoiceOver',
          'Flutter does not support VoiceOver',
        ],
        correctIndex: 1,
        explanation:
            'TalkBack and VoiceOver have different implementations and '
            'occasionally behave differently for the same semantics tree. '
            'Platform-specific issues are common for custom components, '
            'complex interactions, and live region announcements. '
            'Always test on both platforms.',
      ),
      QuizQuestion(
        question: 'Which of these is the most important single change you '
            'can make to an app\'s accessibility?',
        options: [
          'Adding semantic labels to every unlabelled interactive element',
          'Increasing all font sizes by 20%',
          'Adding a dark mode',
          'Removing all animations',
        ],
        correctIndex: 0,
        explanation:
            'Unlabelled interactive elements (buttons, links, icons) '
            'are completely invisible to screen reader users. Adding labels '
            'to these elements is the highest-impact single change because '
            'it determines whether the app is *usable at all* — not just '
            'slightly more comfortable.',
      ),
      QuizQuestion(
        question: 'A colleague says "we don\'t need to worry about accessibility '
            'because only 1% of our users have disabilities." '
            'What is the best response?',
        options: [
          'They are right — focus on the 99%',
          'Accessibility also benefits: users in bright sunlight, users with '
              'temporary injuries, older users, and improves SEO and app-store '
              'ratings for everyone',
          'Accessibility should be a separate app',
          'Accessibility is only legally required for government apps',
        ],
        correctIndex: 1,
        explanation:
            'The "1%" argument misses the breadth of accessibility. '
            'Improvements for users with disabilities typically improve the '
            'experience for everyone: better contrast helps in sunlight, '
            'larger touch targets help users in motion, semantic labels '
            'improve search indexing, and accessible forms reduce error '
            'rates for all users. Accessibility is not a zero-sum trade-off.',
      ),
    ],
  ),
);
