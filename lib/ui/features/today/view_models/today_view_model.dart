import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/class_session.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../core/utils/time_utils.dart';

/// ViewModel for the Today Dashboard screen.
///
/// ## Flutter Learning Note:
/// A ViewModel extends `ChangeNotifier` to expose reactive state to the UI.
/// When we call `notifyListeners()`, any widget using `ListenableBuilder`
/// to listen to this ViewModel will automatically rebuild.
///
/// This ViewModel also demonstrates a **periodic timer** — it refreshes
/// every 60 seconds to keep the countdown display live without the user
/// needing to manually pull-to-refresh.
class TodayViewModel extends ChangeNotifier {
  final RoutineRepository repository;
  Timer? _refreshTimer;

  TodayViewModel({required this.repository}) {
    // Listen for repository data changes (e.g., new class imported)
    repository.addListener(_onDataChanged);

    // Refresh countdown every 60 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => notifyListeners(),
    );
  }

  void _onDataChanged() => notifyListeners();

  // --- Exposed State ---

  /// Greeting based on time of day: "Good Morning", "Good Afternoon", etc.
  String get greeting => TimeUtils.greeting();

  /// Current date formatted as "Sunday, Sep 21".
  String get formattedDate {
    final now = DateTime.now();
    final dayName = TimeUtils.getDayName(now.weekday);
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$dayName, ${months[now.month]} ${now.day}';
  }

  /// Today's classes sorted by start time.
  List<ClassSession> get todaySessions => repository.getTodaySessions();

  /// The next upcoming class (could be today or a future day).
  ClassSession? get nextClass => repository.getNextUpcomingSession();

  /// The currently active class, if any.
  ClassSession? get currentClass => repository.getCurrentlyActiveSession();

  /// Human-readable countdown to the next class.
  String get nextClassCountdown {
    final next = nextClass;
    if (next == null) return '';
    return TimeUtils.timeUntilNext(next);
  }

  /// Whether there are any classes at all in the routine.
  bool get hasAnyClasses => repository.allSessions.isNotEmpty;

  /// Whether there are classes scheduled today.
  bool get hasClassesToday => todaySessions.isNotEmpty;

  /// Total number of classes today.
  int get todayClassCount => todaySessions.length;

  /// Checks if a specific session is currently active.
  bool isActive(ClassSession session) => TimeUtils.isCurrentlyActive(session);

  /// Checks if a specific session has already passed today.
  bool hasPassed(ClassSession session) {
    final now = DateTime.now();
    if (now.weekday != session.dayOfWeek) return false;
    final nowMinutes = now.hour * 60 + now.minute;
    final endMinutes = session.endHour * 60 + session.endMinute;
    return nowMinutes >= endMinutes;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    repository.removeListener(_onDataChanged);
    super.dispose();
  }
}
