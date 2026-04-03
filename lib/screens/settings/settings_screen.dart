import 'package:flutter/material.dart';

import '../../app_state.dart';
import 'widgets/settings_tile.dart';

/// Intentionally inaccessible settings screen.
///
/// Accessibility failures demonstrated here:
/// - Section headings are plain styled Text — no semantic header role
/// - Switches have no Semantics label — screen readers announce only "Switch"
/// - Slider has no semantics value label
/// - Logout is a styled Text inside a ListTile — no role to indicate it's destructive
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
    return ListView(
      children: [
        // --- Profile section ---
        // Inaccessible: plain styled Text heading, no semantic header role
        _SectionHeader(title: 'Profile'),
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
        _SectionHeader(title: 'Preferences'),
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
        _SectionHeader(title: 'About'),
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
}

/// Plain styled section header — intentionally NOT a semantic heading.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
  }
}
