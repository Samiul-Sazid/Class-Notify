import 'package:flutter/material.dart';
import '../../data/models/class_session.dart';

/// Utility methods for time parsing, formatting, and class schedule calculations.
///
/// ## Flutter Learning Note:
/// Utility classes with static methods are a clean way to organize helper
/// functions without needing to instantiate anything. The underscore prefix
/// convention (`_`) makes members private to the library in Dart.
class TimeUtils {
  TimeUtils._(); // Prevent instantiation

  /// Parses a time string like "09:00", "02:15", "10:15 AM", "14:00"
  /// into a TimeOfDay. Handles both 12-hour and 24-hour formats.
  static TimeOfDay? parseTimeString(String time) {
    time = time.trim();

    // Try "HH:MM AM/PM" format
    final amPmRegex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
    final amPmMatch = amPmRegex.firstMatch(time);
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    // Try "HH:MM" 24-hour format
    final hhmmRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final hhmmMatch = hhmmRegex.firstMatch(time);
    if (hhmmMatch != null) {
      final hour = int.parse(hhmmMatch.group(1)!);
      final minute = int.parse(hhmmMatch.group(2)!);
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return null;
  }

  /// Checks if a class session is currently active right now.
  static bool isCurrentlyActive(ClassSession session) {
    final now = DateTime.now();
    if (now.weekday != session.dayOfWeek) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = session.startHour * 60 + session.startMinute;
    final endMinutes = session.endHour * 60 + session.endMinute;

    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }

  /// Returns a human-readable countdown to the next occurrence of a class.
  /// Examples: "in 25 min", "in 2h 10min", "Tomorrow 09:00", "Wed 11:30"
  static String timeUntilNext(ClassSession session) {
    final now = DateTime.now();
    final today = now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = session.startHour * 60 + session.startMinute;

    // Is it today and hasn't started yet?
    if (today == session.dayOfWeek && nowMinutes < startMinutes) {
      final diff = startMinutes - nowMinutes;
      if (diff < 60) return 'in $diff min';
      final hours = diff ~/ 60;
      final mins = diff % 60;
      return mins > 0 ? 'in ${hours}h ${mins}min' : 'in ${hours}h';
    }

    // Is it currently active?
    if (isCurrentlyActive(session)) {
      final endMinutes = session.endHour * 60 + session.endMinute;
      final remaining = endMinutes - nowMinutes;
      return '$remaining min left';
    }

    // Calculate days until next occurrence
    int daysUntil;
    if (today == session.dayOfWeek && nowMinutes >= startMinutes) {
      daysUntil = 7; // Same day but already passed, next week
    } else if (session.dayOfWeek > today) {
      daysUntil = session.dayOfWeek - today;
    } else {
      daysUntil = 7 - (today - session.dayOfWeek);
    }

    final timeStr = formatTime(session.startHour, session.startMinute);

    if (daysUntil == 1) return 'Tomorrow $timeStr';
    return '${getDayNameShort(session.dayOfWeek)} $timeStr';
  }

  /// Formats hour and minute as "09:00" or "14:15".
  static String formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formats hour and minute as "9:00 AM" or "2:15 PM".
  static String formatTime12h(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Returns the full day name for a Dart weekday integer.
  /// 1 = Monday, ..., 6 = Saturday, 7 = Sunday
  static String getDayName(int dayOfWeek) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[dayOfWeek] ?? 'Unknown';
  }

  /// Returns the short day name: "Mon", "Tue", "Sat", etc.
  static String getDayNameShort(int dayOfWeek) {
    const days = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return days[dayOfWeek] ?? '??';
  }

  /// Converts a day name string to a Dart weekday integer.
  /// Handles: "Saturday" → 6, "Sun" → 7, "Monday" → 1, etc.
  static int? dayNameToWeekday(String dayName) {
    final normalized = dayName.trim().toLowerCase();
    const map = {
      'saturday': 6, 'sat': 6,
      'sunday': 7, 'sun': 7,
      'monday': 1, 'mon': 1,
      'tuesday': 2, 'tue': 2,
      'wednesday': 3, 'wed': 3,
      'thursday': 4, 'thu': 4,
      'friday': 5, 'fri': 5,
    };
    return map[normalized];
  }

  /// Sorts a list of sessions by their start time (ascending).
  static List<ClassSession> sortByTime(List<ClassSession> sessions) {
    final sorted = List<ClassSession>.from(sessions);
    sorted.sort((a, b) {
      final aMin = a.startHour * 60 + a.startMinute;
      final bMin = b.startHour * 60 + b.startMinute;
      return aMin.compareTo(bMin);
    });
    return sorted;
  }

  /// Finds the next upcoming class from now across all days.
  static ClassSession? findNextUpcoming(List<ClassSession> sessions) {
    if (sessions.isEmpty) return null;

    final now = DateTime.now();
    final today = now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;

    // First: look for a class later today
    final todaySessions = sessions
        .where((s) => s.dayOfWeek == today)
        .where((s) => s.startHour * 60 + s.startMinute > nowMinutes)
        .toList();
    if (todaySessions.isNotEmpty) {
      return sortByTime(todaySessions).first;
    }

    // Then: find the earliest class in the next 7 days
    ClassSession? best;
    int bestDaysAway = 8;
    int bestStartMinutes = 24 * 60;

    for (final session in sessions) {
      int daysAway;
      if (session.dayOfWeek > today) {
        daysAway = session.dayOfWeek - today;
      } else if (session.dayOfWeek == today) {
        daysAway = 7; // Already passed today
      } else {
        daysAway = 7 - (today - session.dayOfWeek);
      }

      final startMin = session.startHour * 60 + session.startMinute;
      if (daysAway < bestDaysAway ||
          (daysAway == bestDaysAway && startMin < bestStartMinutes)) {
        best = session;
        bestDaysAway = daysAway;
        bestStartMinutes = startMin;
      }
    }

    return best;
  }

  /// Returns a greeting based on the current time of day.
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
