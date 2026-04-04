import 'package:flutter/foundation.dart';

/// Lightweight state holder updated by [TutorialBridge] from server broadcasts.
/// Drives [TutorialStatusBar] and the nav lock in [AccessBankScaffold].
class TutorialAppState extends ChangeNotifier {
  int chapterIndex = 0;
  int stepIndex = 0;
  int totalSteps = 1;
  String chapterTitle = '';
  String stepTitle = '';
  bool showInspector = false;
  bool isConnected = false;

  /// Which bottom-nav tab index is currently allowed.
  /// null = all tabs are free.
  int? allowedTabIndex;

  void update({
    int? chapterIndex,
    int? stepIndex,
    int? totalSteps,
    String? chapterTitle,
    String? stepTitle,
    bool? showInspector,
    bool? isConnected,
    Object? allowedTabIndex = _sentinel,
  }) {
    if (chapterIndex != null) this.chapterIndex = chapterIndex;
    if (stepIndex != null) this.stepIndex = stepIndex;
    if (totalSteps != null) this.totalSteps = totalSteps;
    if (chapterTitle != null) this.chapterTitle = chapterTitle;
    if (stepTitle != null) this.stepTitle = stepTitle;
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
