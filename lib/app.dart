import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/account_overview/account_overview_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/access_bank_scaffold.dart';

class AccessBankApp extends StatefulWidget {
  const AccessBankApp({super.key});

  @override
  State<AccessBankApp> createState() => _AccessBankAppState();
}

class _AccessBankAppState extends State<AccessBankApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
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
            '/guide': (_) => const _GuideScreen(),
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
                    builder: (_) => _GuideChapterScreen(chapter: n),
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
// Guide screens — placeholders for tutorial content
// ---------------------------------------------------------------------------

class _GuideScreen extends StatelessWidget {
  const _GuideScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Guide')),
      body: const Center(child: Text('Guide')),
    );
  }
}

class _GuideChapterScreen extends StatelessWidget {
  const _GuideChapterScreen({required this.chapter});

  final int chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapter $chapter')),
      body: Center(child: Text('Guide — Chapter $chapter')),
    );
  }
}
