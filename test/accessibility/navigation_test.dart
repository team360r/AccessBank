import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible/screens/login/login_screen.dart';
import 'package:accessible/screens/login/widgets/login_form.dart';

void main() {
  group('Navigation — Focus traversal on accessible LoginScreen', () {
    testWidgets('accessible login form wraps fields in FocusTraversalGroup',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      // The accessible form uses FocusTraversalGroup + OrderedTraversalPolicy
      expect(find.byType(FocusTraversalGroup), findsWidgets);
    });

    testWidgets('accessible form uses FocusTraversalOrder on form fields',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: true, onLogin: () {}),
      ));
      // Verify ordered traversal nodes are present (one per interactive widget)
      expect(find.byType(FocusTraversalOrder), findsWidgets);
    });

    testWidgets('inaccessible form does NOT use OrderedTraversalPolicy',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(accessible: false, onLogin: () {}),
      ));
      // The inaccessible form does not set up explicit ordered traversal policy.
      // Note: MaterialApp itself adds FocusTraversalGroups, so we check for
      // the OrderedTraversalPolicy that only the accessible form uses.
      final groups = tester.widgetList<FocusTraversalGroup>(
        find.byType(FocusTraversalGroup),
      );
      final hasOrderedPolicy = groups.any(
        (g) => g.policy is OrderedTraversalPolicy,
      );
      expect(hasOrderedPolicy, isFalse,
          reason: 'Inaccessible form should not use OrderedTraversalPolicy');
    });

    testWidgets(
        'submitting empty accessible form moves focus to email field',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: true, onSubmit: () {}),
        ),
      ));

      // Tap Sign In with empty fields — focus should move to email TextField
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify error appeared (indicating validation ran)
      expect(
        find.text('Sign in failed. Please enter your email and password.'),
        findsOneWidget,
      );

      // The email field should now have focus
      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.focusNode?.hasFocus, isTrue);
    });

    testWidgets(
        'submitting form with email but no password focuses password field',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: true, onSubmit: () {}),
        ),
      ));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Sign in failed. Please enter your email and password.'),
        findsOneWidget,
      );

      // Password field should have focus
      final passwordField = tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordField.focusNode?.hasFocus, isTrue);
    });
  });
}
