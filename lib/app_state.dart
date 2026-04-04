import 'package:flutter/foundation.dart';

/// Central state holder for the AccessBank app.
///
/// Tracks login status, which tab is active, and whether we are showing the
/// accessible or inaccessible version of the UI.
///
/// Call [ChangeNotifier.notifyListeners] indirectly through the public
/// mutation methods so consumers are always rebuilt after state changes.
class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _accessible = false;
  int _currentTab = 0;

  /// Whether the user has authenticated.
  bool get isLoggedIn => _isLoggedIn;

  /// Whether to render the accessible version of the UI.
  ///
  /// When [false] screens intentionally use poor contrast and missing labels
  /// so students can observe accessibility failures. When [true] screens
  /// render with WCAG AA-compliant colours and descriptive labels.
  bool get accessible => _accessible;

  /// Index of the currently selected bottom-navigation tab.
  ///
  /// 0 = Overview, 1 = Transactions, 2 = Transfer, 3 = Settings.
  int get currentTab => _currentTab;

  /// Marks the user as logged in and notifies listeners.
  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Marks the user as logged out and resets the active tab.
  void logout() {
    _isLoggedIn = false;
    _currentTab = 0;
    notifyListeners();
  }

  /// Switches the active tab to [index] and notifies listeners.
  void setTab(int index) {
    if (_currentTab == index) return;
    _currentTab = index;
    notifyListeners();
  }

  /// Flips the accessible/inaccessible toggle and notifies listeners.
  void toggleAccessible() {
    _accessible = !_accessible;
    notifyListeners();
  }

  /// Sets the accessible flag to an explicit value (used by the tutorial bridge).
  void setAccessible(bool value) {
    if (_accessible == value) return;
    _accessible = value;
    notifyListeners();
  }

  /// Sets the logged-in state directly (used by tutorial to show login screen).
  void setLoggedIn(bool value) {
    if (_isLoggedIn == value) return;
    _isLoggedIn = value;
    if (!value) _currentTab = 0;
    notifyListeners();
  }
}
