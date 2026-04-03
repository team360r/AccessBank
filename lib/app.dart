import 'package:flutter/material.dart';

import 'app_state.dart';
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
            '/login': (_) => _LoginScreen(appState: _appState),
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
// Login screen — placeholder
// ---------------------------------------------------------------------------

class _LoginScreen extends StatelessWidget {
  const _LoginScreen({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                appState.login();
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
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
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab body — placeholder screens for each tab
// ---------------------------------------------------------------------------

class _TabBody extends StatelessWidget {
  const _TabBody({required this.tab, required this.accessible});

  final int tab;
  final bool accessible;

  static const _titles = [
    'Overview',
    'Transactions',
    'Transfer',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_titles[tab]),
    );
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
