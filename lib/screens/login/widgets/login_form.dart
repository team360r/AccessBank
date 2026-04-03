import 'package:flutter/material.dart';

/// Intentionally inaccessible login form.
///
/// Accessibility failures demonstrated here:
/// - Placeholder text only — vanishes on focus, leaving users confused
/// - No InputDecoration.labelText so screen readers have no persistent label
/// - No error announcements on failed validation
/// - Biometric button has a small 32x32 touch target (below 48x48 minimum)
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Inaccessible: silent validation — no announcement to screen readers
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorText = 'Invalid credentials');
      return;
    }
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Inaccessible: hint text only — no persistent label
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        // Inaccessible: hint text only — no persistent label
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            hintText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          // Inaccessible: plain Text — no semantics announcement, no LiveRegion
          Text(
            _errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        // Inaccessible: vague "Go" label — provides no context for screen readers
        FilledButton(
          onPressed: _submit,
          child: const Text('Go'),
        ),
        const SizedBox(height: 8),
        // Inaccessible: tiny 32x32 button — below WCAG 44x44pt minimum
        Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(Icons.fingerprint),
              // Inaccessible: no tooltip, no semantics label
              onPressed: widget.onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}
