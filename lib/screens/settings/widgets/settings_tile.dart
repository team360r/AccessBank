import 'package:flutter/material.dart';

/// Intentionally inaccessible settings tile.
///
/// Accessibility failures demonstrated here:
/// - No Semantics wrapping the full row — tap target is just the Switch widget
/// - Switches have no labels for screen readers (only announces "Switch, on/off")
/// - The full-row tap that would make the switch easier to hit is absent
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
}
