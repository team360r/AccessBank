import '../chapter_model.dart';

/// Chapter 7 — Dynamic Content & Live Regions
///
/// Covers proactive announcements for screen reader users: filter changes,
/// balance live regions, loading states, accessible snackbars, and
/// announcing route changes.
const Chapter chapter7 = Chapter(
  id: 7,
  title: 'Dynamic Content & Live Regions',
  branchName: 'chapter-7-live',
  description:
      'When content changes dynamically — filters apply, balances update, '
      'data loads, toasts pop up — sighted users see the change instantly. '
      'Screen reader users miss it entirely unless the app announces it. '
      'In this chapter you\'ll use live regions and `SemanticsService` to '
      'keep users informed of every meaningful change, without being noisy.',
  screenFocus: 'Transactions + Overview',
  estimatedMinutes: 20,
  vibe: 'The app talks to you now, in a good way',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Announcing Filter Changes',
      explanation:
          'When the user taps a filter chip on the Transaction List, the '
          'list content changes — but screen reader users only hear "All, '
          'selected" for the chip itself and then silence. They don\'t know '
          'how many transactions matched or what changed.\n\n'
          'Call `SemanticsService.announce()` after applying the filter to '
          'give a useful summary of the new state.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
void _applyFilter(String filter) {
  setState(() {
    _selectedFilter = filter;
    _filteredTransactions = _getFiltered(filter);
  });
}''',
        after: '''
void _applyFilter(String filter) {
  setState(() {
    _selectedFilter = filter;
    _filteredTransactions = _getFiltered(filter);
  });
  final count = _filteredTransactions.length;
  final label = filter == 'All' ? 'all' : filter.toLowerCase();
  SemanticsService.announce(
    'Showing \$count \$label transaction\${count == 1 ? '' : 's'}',
    TextDirection.ltr,
  );
}''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Live Regions for Updates',
      explanation:
          'A **live region** is a widget whose content changes automatically '
          'and whose changes should be announced proactively. Flutter '
          'implements this via `Semantics(liveRegion: true)`.\n\n'
          'The account balance on the Overview screen is a perfect candidate: '
          'when a transfer completes, the balance updates and the live region '
          'ensures the screen reader announces the new value automatically, '
          'without the user having to navigate to that element.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/account_overview.dart',
        before: '''
// Balance updates silently — screen reader users miss the change
Text(
  formattedBalance,
  style: Theme.of(context).textTheme.headlineMedium,
)''',
        after: '''
// Balance change is automatically announced
Semantics(
  liveRegion: true,
  label: 'Account balance: \$formattedBalance',
  child: Text(
    formattedBalance,
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)''',
      ),
      referenceLinks: [
        'https://www.w3.org/WAI/WCAG21/Understanding/status-messages.html',
      ],
    ),
    TutorialStep(
      id: 3,
      title: 'Loading States',
      explanation:
          'When the app is fetching transaction data, sighted users see a '
          'spinner. Screen reader users hear nothing — the list just seems '
          'to disappear and then reappear.\n\n'
          'Add a `Semantics(liveRegion: true)` wrapper around your loading '
          'indicator and announce the loaded state when data arrives.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transaction_list.dart',
        before: '''
if (_isLoading) {
  return const Center(child: CircularProgressIndicator());
}
return TransactionListView(transactions: _transactions);''',
        after: '''
if (_isLoading) {
  return Semantics(
    liveRegion: true,
    label: 'Loading transactions, please wait',
    child: const Center(child: CircularProgressIndicator()),
  );
}
// Announce when loading completes (called once in setState)
// SemanticsService.announce('Transactions loaded', TextDirection.ltr);
return TransactionListView(transactions: _transactions);''',
      ),
    ),
    TutorialStep(
      id: 4,
      title: 'Accessible Snackbars',
      explanation:
          'Flutter\'s default `SnackBar` is announced by screen readers on '
          'most platforms — but the announcement can be missed if it fires '
          'while the user is in the middle of navigating.\n\n'
          'Make snackbars more accessible by:\n'
          '1. Giving the action button an explicit semantic label\n'
          '2. Calling `SemanticsService.announce()` alongside the snackbar '
          'for platforms where auto-announcement is unreliable\n'
          '3. Keeping the message short and specific',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transfer_screen.dart',
        before: '''
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Transfer sent'),
  ),
);''',
        after: '''
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Transfer of \$amount sent successfully'),
    action: SnackBarAction(
      label: 'View receipt',
      onPressed: _openReceipt,
    ),
  ),
);
// Belt-and-suspenders: announce directly for screen readers
SemanticsService.announce(
  'Transfer of \$amount sent successfully',
  TextDirection.ltr,
);''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'Route Announcements',
      explanation:
          'When the user navigates to a new screen in a native app, the OS '
          'usually announces the new screen\'s title. In Flutter, this '
          'happens automatically if you set `RouteSettings.name` or use '
          'named routes.\n\n'
          'For more control — or to announce something richer than just the '
          'route name — implement a `NavigatorObserver` that calls '
          '`SemanticsService.announce()` on `didPush`.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/navigation/accessibility_observer.dart',
        before: '''
// No announcement — screen reader users don't know a new page loaded
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const TransferScreen()),
)''',
        after: '''
// NavigatorObserver announces each route change
class AccessibilityObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? 'New screen';
    SemanticsService.announce(name, TextDirection.ltr);
    super.didPush(route, previousRoute);
  }
}

// Register once in MaterialApp:
// navigatorObservers: [AccessibilityObserver()]''',
      ),
    ),
  ],
  quiz: Quiz(
    title: 'Dynamic Content Quiz',
    questions: [
      QuizQuestion(
        question: 'What does `Semantics(liveRegion: true)` do?',
        options: [
          'Plays a sound when the widget updates',
          'Automatically announces content changes to screen reader users',
          'Prevents the widget from being re-rendered',
          'Marks the widget as interactive',
        ],
        correctIndex: 1,
        explanation:
            'A live region tells the accessibility service to proactively '
            'announce any content change within that node — similar to an '
            'ARIA live region on the web. The user hears the update '
            'automatically without needing to navigate to the element.',
      ),
      QuizQuestion(
        question: 'When is it appropriate to call `SemanticsService.announce()`?',
        options: [
          'On every state change in the app',
          'Only when a dialog opens',
          'For meaningful status changes the user needs to know about but '
              'did not initiate by moving focus',
          'Only on iOS, not Android',
        ],
        correctIndex: 2,
        explanation:
            '`SemanticsService.announce()` is appropriate for status changes '
            'that users need to know about but that do not cause a focus '
            'change: errors, completion messages, filter results, and similar. '
            'Overusing it creates accessibility noise — use it for '
            'genuinely meaningful events.',
      ),
      QuizQuestion(
        question: 'What is the most reliable way to ensure screen reader users '
            'are aware of route changes?',
        options: [
          'Put the route name in every widget\'s label',
          'Use a NavigatorObserver that calls SemanticsService.announce() on push',
          'Add a live region to the AppBar title',
          'Route changes are always announced automatically',
        ],
        correctIndex: 1,
        explanation:
            'A `NavigatorObserver` gives you explicit control over route '
            'announcements. Flutter\'s default announcement may be present '
            'on some platforms but is not consistent — a custom observer '
            'guarantees your message is spoken on every navigation event.',
      ),
    ],
  ),
);
