import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to track and persist app lifecycle state
/// This allows background workers to know if the app is active or closed
class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  static const String _lifecycleKey = 'app_lifecycle_state';
  AppLifecycleState? _currentState;

  /// Initialize the lifecycle observer
  void init() {
    WidgetsBinding.instance.addObserver(this);
    _currentState = WidgetsBinding.instance.lifecycleState;
    _saveLifecycleState(_currentState);
  }

  /// Dispose the lifecycle observer
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;
    _saveLifecycleState(state);
    debugPrint('App lifecycle changed to: $state');
  }

  /// Save lifecycle state to shared preferences
  Future<void> _saveLifecycleState(AppLifecycleState? state) async {
    if (state == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lifecycleKey, state.name);
    } catch (e) {
      debugPrint('Error saving lifecycle state: $e');
    }
  }

  /// Get the current lifecycle state
  AppLifecycleState? get currentState => _currentState;

  /// Check if app is in foreground (active/visible)
  bool get isAppInForeground {
    return _currentState == AppLifecycleState.resumed ||
        _currentState == AppLifecycleState.inactive;
  }

  /// Check if app is in background (minimized but not closed)
  bool get isAppInBackground {
    return _currentState == AppLifecycleState.paused ||
        _currentState == AppLifecycleState.hidden;
  }

  /// Check if app is detached (closed)
  bool get isAppClosed {
    return _currentState == AppLifecycleState.detached;
  }

  /// Get stored lifecycle state from shared preferences
  /// This is useful for background workers to check app state
  static Future<String?> getStoredLifecycleState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lifecycleKey);
    } catch (e) {
      debugPrint('Error getting stored lifecycle state: $e');
      return null;
    }
  }

  /// Check if app is active based on stored state
  /// Returns true if app is in foreground or background (not closed)
  static Future<bool> isAppActive() async {
    final state = await getStoredLifecycleState();
    if (state == null) return false;

    // App is active if it's resumed, inactive, paused, or hidden
    // App is NOT active if it's detached
    return state != AppLifecycleState.detached.name;
  }
}
