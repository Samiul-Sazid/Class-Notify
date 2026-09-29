import 'package:flutter/material.dart';
import '../../../../data/models/class_session.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../core/utils/time_utils.dart';

/// ViewModel for the weekly timetable screen.
///
/// Manages the selected day tab and exposes the filtered class list.
class TimetableViewModel extends ChangeNotifier {
  final RoutineRepository repository;

  /// Currently selected day (Dart weekday: 1=Mon, 6=Sat, 7=Sun).
  int _selectedDay;

  TimetableViewModel({required this.repository})
      : _selectedDay = DateTime.now().weekday {
    repository.addListener(_onDataChanged);
  }

  void _onDataChanged() => notifyListeners();

  // --- State ---

  int get selectedDay => _selectedDay;

  /// The ordered list of days for the academic week (Sat-Thu by default).
  List<int> get weekDays => repository.settings.orderedWeekDays;

  /// Sessions for the currently selected day, sorted by time.
  List<ClassSession> get sessionsForSelectedDay =>
      repository.getSessionsForDay(_selectedDay);

  /// Number of classes per day (for tab badges).
  Map<int, int> get dayClassCounts => repository.dayClassCounts;

  /// All sessions across all days.
  List<ClassSession> get allSessions => repository.allSessions;

  /// Short day name for display, e.g. "Sat", "Mon".
  String dayNameShort(int day) => TimeUtils.getDayNameShort(day);

  /// Full day name for display, e.g. "Saturday", "Monday".
  String dayNameFull(int day) => TimeUtils.getDayName(day);

  // --- Actions ---

  /// Selects a different day tab.
  void selectDay(int day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  /// Deletes a class session.
  Future<void> deleteSession(String id) async {
    await repository.deleteSession(id);
  }

  /// Toggles the notification for a class session.
  Future<void> toggleNotification(String id) async {
    await repository.toggleNotification(id);
  }

  /// Adds or updates a class session.
  Future<void> saveSession(ClassSession session) async {
    final existing = repository.allSessions.any((s) => s.id == session.id);
    if (existing) {
      await repository.updateSession(session);
    } else {
      await repository.addSession(session);
    }
  }

  @override
  void dispose() {
    repository.removeListener(_onDataChanged);
    super.dispose();
  }
}
