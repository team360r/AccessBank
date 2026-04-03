import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../app_state.dart';
import 'widgets/settings_tile.dart';

/// Settings screen for AccessBank.
///
/// When [accessible] = false this is intentionally inaccessible:
/// - Section headings are plain styled Text — no semantic header role
/// - Switches have no Semantics label — screen readers announce only "Switch"
/// - Slider has no semantics value label
/// - Logout is a styled Text inside a ListTile — no role to indicate it's destructive
///
/// When [accessible] = true:
/// - Section headings use Semantics(header: true)
/// - Each switch tile has a Semantics label with state description
/// - Switch changes are announced via SemanticsService
/// - The entire tile row is tappable (48x48 min touch target)
/// - Slider has semanticFormatterCallback for screen readers
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.accessible,
    required this.appState,
  });

  final bool accessible;
  final AppState appState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  double _textSize = 1.0;
  bool _notifications = true;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    return widget.accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
    return ListView(
      children: [
        // --- Profile section ---
        // Inaccessible: plain styled Text heading, no semantic header role
        _SectionHeader(title: 'Profile', accessible: false),
        SettingsTile(
          icon: Icons.person_outlined,
          title: 'Alex Johnson',
          subtitle: 'Name',
        ),
        SettingsTile(
          icon: Icons.email_outlined,
          title: 'alex@email.com',
          subtitle: 'Email',
        ),

        // --- Preferences section ---
        _SectionHeader(title: 'Preferences', accessible: false),
        SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          trailing: Switch(
            // Inaccessible: no semantics label — screen reader says "Switch, on/off"
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.text_fields_outlined),
              const SizedBox(width: 16),
              const Expanded(child: Text('Text Size')),
              // Inaccessible: no semantics value label on slider
              Expanded(
                flex: 2,
                child: Slider(
                  value: _textSize,
                  min: 0.8,
                  max: 2.0,
                  onChanged: (v) => setState(() => _textSize = v),
                ),
              ),
            ],
          ),
        ),
        SettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          trailing: Switch(
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
        ),
        SettingsTile(
          icon: Icons.fingerprint_outlined,
          title: 'Biometric Login',
          trailing: Switch(
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
        ),

        // --- About section ---
        _SectionHeader(title: 'About', accessible: false),
        SettingsTile(
          icon: Icons.info_outlined,
          title: 'App Version',
          subtitle: '1.0.0',
        ),
        SettingsTile(
          icon: Icons.help_outline,
          title: 'Help',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        // Inaccessible: red text logout — no semantic role indicating destructive action
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            widget.appState.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    return ListView(
      children: [
        // --- Profile section ---
        // Accessible: Semantics(header: true) so screen readers navigate by heading
        _SectionHeader(title: 'Profile', accessible: true),
        SettingsTile(
          accessible: true,
          icon: Icons.person_outlined,
          title: 'Alex Johnson',
          subtitle: 'Name',
        ),
        SettingsTile(
          accessible: true,
          icon: Icons.email_outlined,
          title: 'alex@email.com',
          subtitle: 'Email',
        ),

        // --- Preferences section ---
        _SectionHeader(title: 'Preferences', accessible: true),
        // Accessible: entire row is tappable, switch has Semantics label + state
        SettingsTile(
          accessible: true,
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          switchValue: _darkMode,
          onSwitchChanged: (v) => setState(() => _darkMode = v),
        ),
        // Accessible: slider with semanticFormatterCallback
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                const Icon(Icons.text_fields_outlined),
                const SizedBox(width: 16),
                const Expanded(child: Text('Text Size')),
                Expanded(
                  flex: 2,
                  child: Semantics(
                    label: 'Text size slider',
                    child: Slider(
                      value: _textSize,
                      min: 0.8,
                      max: 2.0,
                      // Accessible: announces the value as human-readable percentage
                      semanticFormatterCallback: (v) =>
                          '${(v * 100).round()} percent',
                      onChanged: (v) => setState(() => _textSize = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SettingsTile(
          accessible: true,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          switchValue: _notifications,
          onSwitchChanged: (v) => setState(() => _notifications = v),
        ),
        SettingsTile(
          accessible: true,
          icon: Icons.fingerprint_outlined,
          title: 'Biometric Login',
          switchValue: _biometric,
          onSwitchChanged: (v) => setState(() => _biometric = v),
        ),

        // --- About section ---
        _SectionHeader(title: 'About', accessible: true),
        SettingsTile(
          accessible: true,
          icon: Icons.info_outlined,
          title: 'App Version',
          subtitle: '1.0.0',
        ),
        SettingsTile(
          accessible: true,
          icon: Icons.help_outline,
          title: 'Help',
          trailing: const ExcludeSemantics(child: Icon(Icons.chevron_right)),
          onTap: () {},
        ),
        // Accessible: Semantics with button role and descriptive label
        Semantics(
          button: true,
          label: 'Logout',
          hint: 'Double tap to sign out of AccessBank',
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                widget.appState.logout();
                SemanticsService.sendAnnouncement(
                  View.of(context),
                  'Logged out',
                  TextDirection.ltr,
                );
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Section header for the settings screen.
///
/// When [accessible] = true, uses Semantics(header: true) for screen reader navigation.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.accessible});

  final String title;
  final bool accessible;

  @override
  Widget build(BuildContext context) {
    final textWidget = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.8,
        ),
      ),
    );

    if (accessible) {
      // Accessible: Semantics header role for screen reader navigation
      return Semantics(
        header: true,
        child: textWidget,
      );
    }

    // Inaccessible: plain styled Text heading, no semantic header role
    return textWidget;
  }
}
