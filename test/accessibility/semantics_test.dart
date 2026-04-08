import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessbank/screens/account_overview/widgets/account_card.dart';
import 'package:accessbank/screens/login/widgets/login_form.dart';
import 'package:accessbank/screens/settings/widgets/settings_tile.dart';
import 'package:accessbank/data/mock_accounts.dart';

void main() {
  group('Semantics — AccountCard', () {
    testWidgets('accessible account card has a semantic label with account name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AccountCard(
            account: MockAccounts.everydayChecking,
            accessible: true,
          ),
        ),
      ));

      // find.semantics.byLabel with a RegExp finds nodes whose label
      // contains the account name
      expect(
        find.semantics.byLabel(RegExp('Everyday Checking')),
        findsWidgets,
        reason: 'Accessible account card should have semantic label with account name',
      );

      handle.dispose();
    });

    testWidgets('accessible account card label includes balance description',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AccountCard(
            account: MockAccounts.everydayChecking,
            accessible: true,
          ),
        ),
      ));

      // The spellOutAmount function adds "dollars" to the balance description
      expect(
        find.semantics.byLabel(RegExp('balance.*dollars', caseSensitive: false)),
        findsWidgets,
        reason: 'Accessible account card should include spelled-out balance in label',
      );

      handle.dispose();
    });

    testWidgets('inaccessible account card has no merged semantic label with balance',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AccountCard(
            account: MockAccounts.everydayChecking,
            accessible: false,
          ),
        ),
      ));

      // The inaccessible card has no merged label combining name + balance
      expect(
        find.semantics.byLabel(RegExp('balance.*dollars', caseSensitive: false)),
        findsNothing,
        reason: 'Inaccessible card should not have merged balance semantic label',
      );

      handle.dispose();
    });
  });

  group('Semantics — LoginForm', () {
    testWidgets('accessible form fields have persistent label text',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: true, onSubmit: () {}),
        ),
      ));
      // Accessible form uses labelText which remains visible as a floating label
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });

    testWidgets('accessible biometric button has a semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: true, onSubmit: () {}),
        ),
      ));

      // The biometric Semantics node has label 'Sign in with biometrics'
      expect(
        find.semantics.byLabel('Sign in with biometrics'),
        findsWidgets,
        reason: 'Accessible biometric button should have semantic label',
      );

      handle.dispose();
    });

    testWidgets('accessible error message uses a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: true, onSubmit: () {}),
        ),
      ));

      // Trigger validation error
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // The liveRegion flag is set on the error text's Semantics node
      expect(
        find.semantics.byFlag(SemanticsFlag.isLiveRegion),
        findsWidgets,
        reason: 'Accessible error text should be in a live region',
      );

      handle.dispose();
    });

    testWidgets('inaccessible form does not have biometric semantic label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LoginForm(accessible: false, onSubmit: () {}),
        ),
      ));

      expect(
        find.semantics.byLabel('Sign in with biometrics'),
        findsNothing,
        reason: 'Inaccessible biometric button should not have semantic label',
      );

      handle.dispose();
    });
  });

  group('Semantics — SettingsTile', () {
    testWidgets('accessible switch tile has semantic label with "off" when toggled off',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            accessible: true,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            switchValue: false,
            onSwitchChanged: (_) {},
          ),
        ),
      ));

      // The Semantics wrapper has label 'Dark Mode, currently off'
      expect(
        find.semantics.byLabel(RegExp('Dark Mode.*off')),
        findsWidgets,
        reason: 'Accessible switch tile should have label including "off" state',
      );

      handle.dispose();
    });

    testWidgets('accessible switch tile with value=true has label with "on"',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            accessible: true,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            switchValue: true,
            onSwitchChanged: (_) {},
          ),
        ),
      ));

      expect(
        find.semantics.byLabel(RegExp('Notifications.*on')),
        findsWidgets,
        reason: 'Accessible switch tile with value=true should include "on" in label',
      );

      handle.dispose();
    });

    testWidgets('accessible switch tile is marked as toggled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            accessible: true,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            switchValue: true,
            onSwitchChanged: (_) {},
          ),
        ),
      ));

      // Semantics(toggled: true) sets the isToggled flag
      expect(
        find.semantics.byFlag(SemanticsFlag.isToggled),
        findsWidgets,
        reason: 'Accessible switch tile with switchValue=true should be isToggled',
      );

      handle.dispose();
    });
  });
}
