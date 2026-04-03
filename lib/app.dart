import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/account_overview/account_overview_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'theme/app_theme.dart';
import 'tutorial/tutorial_controller.dart';
import 'tutorial/tutorial_overlay.dart';
import 'widgets/access_bank_scaffold.dart';

class AccessBankApp extends StatefulWidget {
  const AccessBankApp({super.key});

  @override
  State<AccessBankApp> createState() => _AccessBankAppState();
}

class _AccessBankAppState extends State<AccessBankApp> {
  final AppState _appState = AppState();
  final TutorialController _tutorialController = TutorialController();

  @override
  void dispose() {
    _appState.dispose();
    _tutorialController.dispose();
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
          initialRoute: '/login',
          routes: {
            '/login': (_) => _LoginScreenWrapper(appState: _appState),
            '/home': (_) => _HomeScreen(appState: _appState),
            '/guide': (_) => _GuideScreen(
                  tutorialController: _tutorialController,
                  appState: _appState,
                ),
          },
          onGenerateRoute: (settings) {
            // Handle /guide/chapter-{n}
            final uri = Uri.tryParse(settings.name ?? '');
            if (uri != null) {
              final segments = uri.pathSegments;
              if (segments.length == 2 &&
                  segments[0] == 'guide' &&
                  segments[1].startsWith('chapter-')) {
                final chapterStr = segments[1].replaceFirst('chapter-', '');
                final n = int.tryParse(chapterStr);
                if (n != null) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder: (_) => _GuideChapterScreen(
                      chapter: n,
                      tutorialController: _tutorialController,
                      appState: _appState,
                    ),
                  );
                }
              }
            }
            return null;
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Login screen wrapper
// ---------------------------------------------------------------------------

class _LoginScreenWrapper extends StatelessWidget {
  const _LoginScreenWrapper({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      accessible: appState.accessible,
      onLogin: () {
        appState.login();
        Navigator.of(context).pushReplacementNamed('/home');
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Home screen — scaffold with tab switching
// ---------------------------------------------------------------------------

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AccessBankScaffold(
          accessible: appState.accessible,
          currentIndex: appState.currentTab,
          onTabChanged: appState.setTab,
          body: _TabBody(
            tab: appState.currentTab,
            accessible: appState.accessible,
            appState: appState,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab body — real screens for each tab
// ---------------------------------------------------------------------------

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
    switch (tab) {
      case 0:
        return AccountOverviewScreen(accessible: accessible);
      case 1:
        return TransactionsScreen(accessible: accessible);
      case 2:
        return TransferScreen(accessible: accessible);
      case 3:
        return SettingsScreen(accessible: accessible, appState: appState);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Guide screens — TutorialOverlay wrapping the current banking screen
// ---------------------------------------------------------------------------

class _GuideScreen extends StatelessWidget {
  const _GuideScreen({
    required this.tutorialController,
    required this.appState,
  });

  final TutorialController tutorialController;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: tutorialController,
        builder: (context, _) {
          return TutorialOverlay(
            controller: tutorialController,
            bankingContent: _BankingContentForTutorial(
              appState: appState,
              accessible: tutorialController.showAccessible,
            ),
          );
        },
      ),
    );
  }
}

class _GuideChapterScreen extends StatelessWidget {
  const _GuideChapterScreen({
    required this.chapter,
    required this.tutorialController,
    required this.appState,
  });

  final int chapter;
  final TutorialController tutorialController;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // Navigate the controller to the requested chapter once, after the first
    // frame so the widget tree is stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tutorialController.goToChapter(chapter);
    });

    return Scaffold(
      body: ListenableBuilder(
        listenable: tutorialController,
        builder: (context, _) {
          return TutorialOverlay(
            controller: tutorialController,
            bankingContent: _BankingContentForTutorial(
              appState: appState,
              accessible: tutorialController.showAccessible,
            ),
          );
        },
      ),
    );
  }
}

/// Banking content widget used inside the tutorial overlay.
///
/// Shows the same tab body as [_HomeScreen] but driven by the tutorial
/// controller's [showAccessible] flag rather than [AppState.accessible].
class _BankingContentForTutorial extends StatelessWidget {
  const _BankingContentForTutorial({
    required this.appState,
    required this.accessible,
  });

  final AppState appState;
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return AccessBankScaffold(
          accessible: accessible,
          currentIndex: appState.currentTab,
          onTabChanged: appState.setTab,
          body: _TabBody(
            tab: appState.currentTab,
            accessible: accessible,
            appState: appState,
          ),
        );
      },
    );
  }
}
