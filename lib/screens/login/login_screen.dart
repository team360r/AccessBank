import 'package:flutter/material.dart';

import 'widgets/login_form.dart';

/// Login screen for AccessBank.
///
/// Displays the bank logo, a welcome heading, and a [LoginForm].
/// On successful form submission, navigates to ['/home'].
///
/// The [accessible] parameter is accepted for API consistency but the
/// accessible variant will be implemented in Phase 5. For now both paths
/// render the same inaccessible version.
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
                // Bank logo — inaccessible: no Semantics label on the icon
                const Icon(
                  Icons.account_balance,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to AccessBank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                LoginForm(onSubmit: onLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
