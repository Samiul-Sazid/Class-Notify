import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/class_session.dart';
import '../../data/models/user_settings.dart';

/// Handles local persistence using SharedPreferences.
///
/// ## Flutter Learning Note:
/// SharedPreferences is an async key-value store that persists data across
/// app restarts. It's perfect for small datasets like a weekly timetable.
///
/// For larger datasets (thousands of records), you'd use SQLite via the
/// `sqflite` package or Hive — but for a typical class routine (~20-30
/// sessions), SharedPreferences is fast and simple.
///
/// Notice how this class is a **Service** in the Clean Architecture sense:
/// it wraps an external API (SharedPreferences) and exposes clean methods.
/// The Repository layer consumes this service.
class StorageService {
  static const String _sessionsKey = 'class_sessions';
  static const String _settingsKey = 'user_settings';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences. Must be called before any read/write.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Class Sessions ---

  /// Saves all class sessions to local storage.
  Future<void> saveSessions(List<ClassSession> sessions) async {
    await init();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_sessionsKey, jsonEncode(jsonList));
  }

  /// Loads all class sessions from local storage.
  Future<List<ClassSession>> loadSessions() async {
    await init();
    final jsonString = _prefs!.getString(_sessionsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) =>
              ClassSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If data is corrupt, return empty list (don't crash).
      return [];
    }
  }

  // --- User Settings ---

  /// Saves user settings to local storage.
  Future<void> saveSettings(UserSettings settings) async {
    await init();
    await _prefs!.setString(_settingsKey, settings.toJsonString());
  }

  /// Loads user settings from local storage (returns defaults if not found).
  Future<UserSettings> loadSettings() async {
    await init();
    final jsonString = _prefs!.getString(_settingsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return const UserSettings();
    }

    try {
      return UserSettings.fromJsonString(jsonString);
    } catch (e) {
      return const UserSettings();
    }
  }

  // --- Data Management ---

  /// Clears all stored data (sessions + settings).
  Future<void> clearAll() async {
    await init();
    await _prefs!.remove(_sessionsKey);
    await _prefs!.remove(_settingsKey);
  }
}
