import 'package:flutter/foundation.dart';
import '../../data/models/class_session.dart';
import '../../data/models/user_settings.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/time_utils.dart';

/// Central data coordinator — the single source of truth for schedule data.
///
/// ## Flutter Learning Note:
/// The Repository pattern serves two key purposes:
/// 1. **Abstraction**: ViewModels don't know or care HOW data is stored.
///    They just call `getAllSessions()` and get a list back.
/// 2. **Coordination**: Every time data changes (add, delete, import),
///    the repository automatically syncs notifications. This prevents
///    bugs where you forget to update alarms after editing a class.
///
/// This class extends `ChangeNotifier` so that ViewModels can listen
/// for data changes and automatically rebuild the UI.
class RoutineRepository extends ChangeNotifier {
  final StorageService storage;
  final NotificationService notifications;

  List<ClassSession> _sessions = [];
  UserSettings _settings = const UserSettings();

  RoutineRepository({
    required this.storage,
    required this.notifications,
  });

  // --- Getters ---

  /// All stored class sessions.
  List<ClassSession> get allSessions => List.unmodifiable(_sessions);

  /// Whether any classes exist in the repository.
  bool get hasClasses => _sessions.isNotEmpty;

  /// Current user settings.
  UserSettings get settings => _settings;

  // --- Initialization ---

  /// Loads sessions and settings from local storage. Call once at app startup.
  Future<void> init() async {
    _sessions = await storage.loadSessions();
    _settings = await storage.loadSettings();
    notifyListeners();
  }

  // --- Query Methods ---

  /// Returns sessions for a specific day of week, sorted by time.
  List<ClassSession> getSessionsForDay(int dayOfWeek) {
    final daySessions =
        _sessions.where((s) => s.dayOfWeek == dayOfWeek).toList();
    return TimeUtils.sortByTime(daySessions);
  }

  /// Returns today's sessions, sorted by time.
  List<ClassSession> getTodaySessions() {
    return getSessionsForDay(DateTime.now().weekday);
  }

  /// Returns the next upcoming class from now.
  ClassSession? getNextUpcomingSession() {
    return TimeUtils.findNextUpcoming(_sessions);
  }

  /// Returns the currently active class, or null.
  ClassSession? getCurrentlyActiveSession() {
    try {
      return _sessions.firstWhere(
        (s) => TimeUtils.isCurrentlyActive(s),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns a map of dayOfWeek → number of classes for badge display.
  Map<int, int> get dayClassCounts {
    final counts = <int, int>{};
    for (final session in _sessions) {
      counts[session.dayOfWeek] = (counts[session.dayOfWeek] ?? 0) + 1;
    }
    return counts;
  }

  // --- Mutation Methods ---

  /// Adds a new class session and syncs notifications.
  Future<void> addSession(ClassSession session) async {
    _sessions.add(session);
    await _persist();
  }

  /// Updates an existing session (matched by ID) and syncs notifications.
  Future<void> updateSession(ClassSession updated) async {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      await _persist();
    }
  }

  /// Deletes a session by ID and cancels its notification.
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await notifications.cancelClassAlarm(id);
    await _persist();
  }

  /// Toggles the notification enabled state for a specific session.
  Future<void> toggleNotification(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final session = _sessions[index];
      _sessions[index] = session.copyWith(
        isNotificationEnabled: !session.isNotificationEnabled,
      );
      await _persist();
    }
  }

  /// Imports a batch of sessions (e.g., from AI parsing).
  /// Optionally clears existing sessions first.
  Future<void> importSessions(
    List<ClassSession> newSessions, {
    bool clearExisting = false,
  }) async {
    if (clearExisting) {
      _sessions.clear();
      await notifications.cancelAll();
    }
    _sessions.addAll(newSessions);
    await _persist();
  }

  /// Clears all class sessions and notifications.
  Future<void> clearAll() async {
    _sessions.clear();
    await notifications.cancelAll();
    await storage.saveSessions([]);
    notifyListeners();
  }

  // --- Settings ---

  /// Updates user settings and reschedules notifications if lead time changed.
  Future<void> updateSettings(UserSettings newSettings) async {
    final leadChanged =
        _settings.reminderLeadMinutes != newSettings.reminderLeadMinutes;
    _settings = newSettings;
    await storage.saveSettings(_settings);

    if (leadChanged) {
      await _syncNotifications();
    }
    notifyListeners();
  }

  // --- Internal ---

  /// Persists current sessions to storage and syncs all notifications.
  Future<void> _persist() async {
    await storage.saveSessions(_sessions);
    await _syncNotifications();
    notifyListeners();
  }

  /// Cancels all existing alarms and reschedules for all enabled sessions.
  Future<void> _syncNotifications() async {
    await notifications.rescheduleAll(
      _sessions,
      leadMinutes: _settings.reminderLeadMinutes,
    );
  }
}
