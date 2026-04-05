import 'package:flutter/foundation.dart';

/// Lightweight state holder updated by [TutorialBridge] from server broadcasts.
/// Drives the a11y inspector overlay and the nav lock in [AccessBankScaffold].
class TutorialAppState extends ChangeNotifier {
  bool showInspector = false;
  bool isConnected = false;

  /// Which bottom-nav tab index is currently allowed.
  /// null = all tabs are free.
  int? allowedTabIndex;

  void update({
    bool? showInspector,
    bool? isConnected,
    Object? allowedTabIndex = _sentinel,
  }) {
    if (showInspector != null) this.showInspector = showInspector;
    if (isConnected != null) this.isConnected = isConnected;
    if (!identical(allowedTabIndex, _sentinel)) {
      this.allowedTabIndex = allowedTabIndex as int?;
    }
    notifyListeners();
  }
}

/// Sentinel for nullable int update (distinguishes "not set" from "set to null").
const _sentinel = Object();
