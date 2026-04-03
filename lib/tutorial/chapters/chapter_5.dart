import '../chapter_model.dart';

/// Chapter 5 — Forms That Work for Everyone
///
/// Covers accessible form design: proper labels, announcing errors via
/// SemanticsService, moving focus to the first error field, live validation,
/// and smart input types.
const Chapter chapter5 = Chapter(
  id: 5,
  title: 'Forms That Work for Everyone',
  branchName: 'chapter-5-forms',
  description:
      'Forms are where accessibility failures hit hardest. An inaccessible '
      'login screen locks users out of their own account; an inaccessible '
      'transfer form can cost them real money. In this chapter you\'ll '
      'properly label every field, announce errors through assistive '
      'technology, move focus to problems, and use smart keyboard types '
      'to make data entry effortless.',
  screenFocus: 'Login + Transfer',
  estimatedMinutes: 25,
  vibe: 'Forms are where accessibility really saves people',
  steps: [
    TutorialStep(
      id: 1,
      title: 'Label Everything',
      explanation:
          'Every form field needs a visible label — not just a placeholder '
          '(which disappears when the user starts typing). Use '
          '`InputDecoration.labelText` for the persistent floating label and '
          '`InputDecoration.hintText` for the secondary placeholder hint.\n\n'
          'Flutter\'s `TextField` with a proper `labelText` automatically '
          'provides semantics to screen readers, so users hear "Email, text '
          'field, double tap to edit" rather than just "text field".',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
// Placeholder disappears on input; screen reader says "text field"
TextField(
  decoration: const InputDecoration(
    hintText: 'Enter your email',
  ),
  controller: _emailController,
)''',
        after: '''
// Label floats above the field; screen reader says "Email, text field"
TextField(
  decoration: const InputDecoration(
    labelText: 'Email address',
    hintText: 'e.g. name@example.com',
  ),
  controller: _emailController,
)''',
      ),
    ),
    TutorialStep(
      id: 2,
      title: 'Announce Errors',
      explanation:
          'When form validation fails, sighted users can see red error text '
          'below the field. Screen reader users won\'t know anything went '
          'wrong unless you tell them.\n\n'
          '`SemanticsService.announce()` inserts a message into the '
          'platform\'s accessibility announcement queue — like a "live region" '
          'update that is spoken without requiring the user to move focus.\n\n'
          'Call it after validation so the user immediately hears what went '
          'wrong.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
void _validateAndSubmit() {
  if (_emailController.text.isEmpty) {
    setState(() {
      _emailError = 'Email is required';
    });
    return;
  }
  _signIn();
}''',
        after: '''
void _validateAndSubmit() {
  if (_emailController.text.isEmpty) {
    setState(() {
      _emailError = 'Email is required';
    });
    // Announce the error for screen reader users
    SemanticsService.announce(
      'Error: Email is required',
      TextDirection.ltr,
    );
    return;
  }
  _signIn();
}''',
      ),
      referenceLinks: [
        'https://api.flutter.dev/flutter/semantics/SemanticsService-class.html',
      ],
    ),
    TutorialStep(
      id: 3,
      title: 'Focus to Error',
      explanation:
          'Announcing an error is a good start, but the user still needs to '
          'find the problematic field. Move focus to the first field that '
          'has an error so the user is already in the right place to fix it.\n\n'
          'Attach a `FocusNode` to each field, keep a list of validators, '
          'then after showing errors call `requestFocus()` on the node '
          'corresponding to the first failure.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
// User has to hunt for the error field
void _validateAndSubmit() {
  bool hasError = false;
  if (_emailController.text.isEmpty) {
    setState(() => _emailError = 'Required');
    hasError = true;
  }
  if (_passwordController.text.isEmpty) {
    setState(() => _passwordError = 'Required');
    hasError = true;
  }
  if (!hasError) _signIn();
}''',
        after: '''
// Focus jumps to the first error field automatically
final FocusNode _emailFocus = FocusNode();
final FocusNode _passwordFocus = FocusNode();

void _validateAndSubmit() {
  FocusNode? firstError;

  if (_emailController.text.isEmpty) {
    setState(() => _emailError = 'Email is required');
    firstError ??= _emailFocus;
  }
  if (_passwordController.text.isEmpty) {
    setState(() => _passwordError = 'Password is required');
    firstError ??= _passwordFocus;
  }

  if (firstError != null) {
    firstError.requestFocus();
    SemanticsService.announce(
      'Form has errors. Please review the highlighted fields.',
      TextDirection.ltr,
    );
    return;
  }
  _signIn();
}''',
      ),
    ),
    TutorialStep(
      id: 4,
      title: 'Live Validation',
      explanation:
          'The Transfer screen\'s amount field accepts a dollar value — but '
          'tells the user nothing is wrong until they hit Submit. Real-time '
          'validation with an accessible announcement on each change gives '
          'users immediate feedback as they type.\n\n'
          'Use `onChanged` to validate and `SemanticsService.announce()` '
          'with a short debounce so the announcement does not fire on every '
          'keystroke.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/transfer_screen.dart',
        before: '''
TextField(
  decoration: const InputDecoration(
    labelText: 'Amount',
    prefixText: '\$',
  ),
  controller: _amountController,
  keyboardType: TextInputType.number,
)''',
        after: '''
TextField(
  decoration: InputDecoration(
    labelText: 'Transfer amount',
    prefixText: '\$',
    errorText: _amountError,
  ),
  controller: _amountController,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  onChanged: (value) {
    final amount = double.tryParse(value);
    if (amount == null && value.isNotEmpty) {
      final error = 'Please enter a valid dollar amount';
      setState(() => _amountError = error);
      _debounce(() => SemanticsService.announce(error, TextDirection.ltr));
    } else if (amount != null && amount > _selectedAccount.balance) {
      final error = 'Amount exceeds available balance';
      setState(() => _amountError = error);
      _debounce(() => SemanticsService.announce(error, TextDirection.ltr));
    } else {
      setState(() => _amountError = null);
    }
  },
)''',
      ),
    ),
    TutorialStep(
      id: 5,
      title: 'Smart Input Types',
      explanation:
          'Setting the right `keyboardType` and `autofillHints` on each '
          'field does three things:\n\n'
          '1. Shows the most helpful on-screen keyboard (email keyboard '
          'for email, number pad for amounts)\n'
          '2. Enables AutoFill so password managers and iOS/Android autofill '
          'can populate fields\n'
          '3. Helps screen readers announce the field type correctly\n\n'
          'These are small changes with a big usability impact — especially '
          'for users with motor impairments who find typing difficult.',
      codeDiff: CodeDiff(
        language: 'dart',
        filePath: 'lib/screens/login_screen.dart',
        before: '''
// Generic keyboard; no autofill hints
TextField(
  decoration: const InputDecoration(labelText: 'Email address'),
  controller: _emailController,
)

TextField(
  decoration: const InputDecoration(labelText: 'Password'),
  controller: _passwordController,
  obscureText: true,
)''',
        after: '''
// Email keyboard + autofill support
TextField(
  decoration: const InputDecoration(labelText: 'Email address'),
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  autofillHints: const [AutofillHints.username, AutofillHints.email],
)

// Password keyboard + autofill support
TextField(
  decoration: const InputDecoration(labelText: 'Password'),
  controller: _passwordController,
  obscureText: true,
  textInputAction: TextInputAction.done,
  autofillHints: const [AutofillHints.password],
  onSubmitted: (_) => _validateAndSubmit(),
)''',
      ),
    ),
  ],
  quiz: Quiz(
    title: 'Accessible Forms Quiz',
    questions: [
      QuizQuestion(
        question: 'Why should you use `InputDecoration.labelText` instead of '
            'only `hintText` for form fields?',
        options: [
          'labelText has better typography',
          'hintText is not supported on all platforms',
          'labelText stays visible as a floating label when the user types; '
              'hintText disappears',
          'labelText is required by Flutter',
        ],
        correctIndex: 2,
        explanation:
            '`hintText` disappears as soon as the user starts typing, '
            'leaving them with no label to refer back to. `labelText` '
            'floats above the field and remains visible, which benefits '
            'both sighted users and screen reader users who need context '
            'while editing.',
      ),
      QuizQuestion(
        question: 'What does `SemanticsService.announce()` do?',
        options: [
          'Adds a tooltip to the nearest Semantics widget',
          'Inserts a spoken message into the accessibility announcement queue '
              'without requiring focus change',
          'Logs an accessibility event to the console',
          'Sets the label of the currently focused widget',
        ],
        correctIndex: 1,
        explanation:
            '`SemanticsService.announce()` sends a live-region announcement '
            'to the platform\'s accessibility service. The message is spoken '
            'by the screen reader without the user having to move focus — '
            'ideal for error messages and status updates.',
      ),
      QuizQuestion(
        question: 'Which combination of improvements makes the Transfer '
            'amount field most accessible?',
        options: [
          'labelText + number keyboard + live error announcement',
          'hintText only',
          'Large font size + border colour change',
          'Placeholder text + onSubmitted callback',
        ],
        correctIndex: 0,
        explanation:
            'The accessible amount field combines: a visible `labelText`, '
            'a `numberWithOptions(decimal: true)` keyboard, and a '
            '`SemanticsService.announce()` call in `onChanged` for live '
            'error feedback — giving sighted, screen reader, and motor-impaired '
            'users the best experience.',
      ),
    ],
  ),
);
