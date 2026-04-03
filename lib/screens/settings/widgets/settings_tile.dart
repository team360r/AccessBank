import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Settings tile used on [SettingsScreen].
///
/// When [accessible] = false this is intentionally inaccessible:
/// - No Semantics wrapping the full row — tap target is just the Switch widget
/// - Switches have no labels for screen readers (only announces "Switch, on/off")
/// - The full-row tap that would make the switch easier to hit is absent
///
/// When [accessible] = true:
/// - The entire tile row is tappable (48x48 min touch target)
/// - Switches have Semantics labels with state descriptions
/// - Switch state changes are announced via SemanticsService
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.accessible = false,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
  });

  final IconData icon;
  final String title;
  final bool accessible;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// When non-null, this tile has an accessible Switch with proper semantics.
  final bool? switchValue;

  /// Called when the switch is toggled (accessible variant).
  final ValueChanged<bool>? onSwitchChanged;

  @override
  Widget build(BuildContext context) {
    return accessible
        ? _buildAccessibleVersion(context)
        : _buildInaccessibleVersion(context);
  }

  Widget _buildInaccessibleVersion(BuildContext context) {
    return ListTile(
      // Inaccessible: interaction is on the trailing widget only (e.g. Switch)
      // — tapping the tile row does NOT toggle the switch, so the tap target
      // is only as large as the trailing widget.
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      // Inaccessible: trailing widget (Switch) has no merged semantics label
      trailing: trailing,
    );
  }

  Widget _buildAccessibleVersion(BuildContext context) {
    final hasSwitchControl = switchValue != null && onSwitchChanged != null;

    if (hasSwitchControl) {
      void handleToggle(bool newValue) {
        onSwitchChanged!(newValue);
        SemanticsService.sendAnnouncement(
          View.of(context),
          '$title turned ${newValue ? "on" : "off"}',
          TextDirection.ltr,
        );
      }

      // For switch tiles: wrap entire row so tapping anywhere toggles the switch
      return Semantics(
        label: '$title, currently ${switchValue! ? "on" : "off"}',
        hint: 'Double tap to toggle',
        toggled: switchValue,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => handleToggle(!switchValue!),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: subtitle != null ? Text(subtitle!) : null,
              trailing: ExcludeSemantics(
                child: Switch(
                  value: switchValue!,
                  onChanged: handleToggle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Non-switch tile: just ensure min 48 height and proper tap target
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
      ),
    );
  }
}
