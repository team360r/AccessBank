import 'package:flutter/material.dart';

import 'widgets/login_form.dart';

/// Login screen for AccessBank.
///
/// Displays the bank logo, a welcome heading, and a [LoginForm].
/// On successful form submission, navigates to ['/home'].
///
/// The [accessible] parameter controls which variant is shown:
/// - [accessible] = false: intentionally inaccessible version for tutorial "before" state
/// - [accessible] = true: WCAG AA-compliant version with proper labels, focus management,
///   and screen reader announcements
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.accessible,
    required this.onLogin,
  });

  final bool accessible;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (accessible)
                  // Accessible: Semantics label on the decorative bank icon
                  Semantics(
                    label: 'AccessBank logo',
                    child: const Icon(
                      Icons.account_balance,
                      size: 64,
                    ),
                  )
                else
                  // Inaccessible: no Semantics label on the icon
                  const Icon(
                    Icons.account_balance,
                    size: 64,
                  ),
                const SizedBox(height: 16),
                if (accessible)
                  // Accessible: heading role so screen readers navigate by heading
                  Semantics(
                    header: true,
                    child: const Text(
                      'Welcome to AccessBank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Welcome to AccessBank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 32),
                LoginForm(accessible: accessible, onSubmit: onLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
