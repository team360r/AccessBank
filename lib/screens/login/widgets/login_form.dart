import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Login form for AccessBank.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Placeholder text only — vanishes on focus, leaving users confused
/// - No InputDecoration.labelText so screen readers have no persistent label
/// - No error announcements on failed validation
/// - Biometric button has a small 32x32 touch target (below 48x48 minimum)
///
/// When [accessible] = true this demonstrates WCAG AA-compliant patterns:
/// - Persistent labelText on all fields
/// - SemanticsService.announce() on validation failure
/// - Focus moved to first error field
/// - 48x48 minimum touch targets on all interactive elements
/// - Descriptive button text "Sign In" instead of vague "Go"
/// - FocusTraversalGroup for logical tab order
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.accessible, required this.onSubmit});

  final bool accessible;
  final VoidCallback onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _signInFocusNode = FocusNode();
  final _biometricFocusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _signInFocusNode.dispose();
    _biometricFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.accessible) {
      _submitAccessible();
    } else {
      _submitInaccessible();
    }
  }

  void _submitInaccessible() {
    // Inaccessible: silent validation — no announcement to screen readers
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorText = 'Invalid credentials');
      return;
    }
    widget.onSubmit();
  }

  void _submitAccessible() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      const message = 'Sign in failed. Please enter your email and password.';
      setState(() => _errorText = message);
      // Announce the error to screen readers
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        TextDirection.ltr,
      );
      // Move focus to the first empty field
      if (_emailController.text.isEmpty) {
        _emailFocusNode.requestFocus();
      } else {
        _passwordFocusNode.requestFocus();
      }
      return;
    }
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return widget.accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
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

  Widget _buildAccessibleVersion(BuildContext context) {
    // FocusTraversalGroup ensures logical order: email → password → sign in → biometric
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accessible: persistent labelText — remains visible when field is focused
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),
          ),
          const SizedBox(height: 12),
          // Accessible: persistent labelText on password field
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            // Accessible: Semantics liveRegion so error is announced automatically
            Semantics(
              liveRegion: true,
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Accessible: descriptive "Sign In" button text
          FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: SizedBox(
              height: 48, // Minimum 48x48 touch target
              child: FilledButton(
                focusNode: _signInFocusNode,
                onPressed: _submit,
                child: const Text('Sign In'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Accessible: 48x48 touch target + Semantics label and hint
          Center(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(4),
              child: Semantics(
                label: 'Sign in with biometrics',
                hint: 'Double tap to sign in using fingerprint or face ID',
                button: true,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Tooltip(
                    message: 'Sign in with biometrics',
                    child: IconButton(
                      focusNode: _biometricFocusNode,
                      padding: EdgeInsets.zero,
                      iconSize: 28,
                      icon: const Icon(Icons.fingerprint),
                      onPressed: widget.onSubmit,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
