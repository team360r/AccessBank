import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/account_overview/account_overview_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'theme/app_theme.dart';
import 'tutorial/tutorial_app_state.dart';
import 'tutorial/tutorial_bridge.dart';
import 'tutorial/widgets/tutorial_status_bar.dart';
import 'widgets/access_bank_scaffold.dart';

class AccessBankApp extends StatefulWidget {
  const AccessBankApp({super.key});

  @override
  State<AccessBankApp> createState() => _AccessBankAppState();
}

class _AccessBankAppState extends State<AccessBankApp> {
  final AppState _appState = AppState();
  final TutorialAppState _tutorialState = TutorialAppState();
  late final TutorialBridge _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = TutorialBridge(_appState, _tutorialState);
  }

  @override
  void dispose() {
    _appState.dispose();
    _bridge.dispose();
    _tutorialState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'AccessBank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: _appState.isLoggedIn
              ? _HomeScreen(appState: _appState, tutorialState: _tutorialState)
              : _LoginScreenWrapper(appState: _appState),
        );
      },
    );
  }
}

class _LoginScreenWrapper extends StatelessWidget {
  const _LoginScreenWrapper({required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      accessible: appState.accessible,
      onLogin: appState.login,
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({required this.appState, required this.tutorialState});
  final AppState appState;
  final TutorialAppState tutorialState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, tutorialState]),
      builder: (context, _) {
        return Column(
          children: [
            TutorialStatusBar(state: tutorialState),
            Expanded(
              child: AccessBankScaffold(
                accessible: appState.accessible,
                currentIndex: appState.currentTab,
                onTabChanged: appState.setTab,
                allowedTabIndex: tutorialState.allowedTabIndex,
                body: _TabBody(
                  tab: appState.currentTab,
                  accessible: appState.accessible,
                  appState: appState,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.tab,
    required this.accessible,
    required this.appState,
  });
  final int tab;
  final bool accessible;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      0 => AccountOverviewScreen(accessible: accessible),
      1 => TransactionsScreen(accessible: accessible),
      2 => TransferScreen(accessible: accessible),
      3 => SettingsScreen(accessible: accessible, appState: appState),
      _ => const SizedBox.shrink(),
    };
  }
}
