import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../../data/models/class_session.dart';

/// Manages local notifications and scheduled weekly alarms.
///
/// ## Flutter Learning Note:
/// `flutter_local_notifications` is the standard package for scheduling
/// notifications on Android, iOS, macOS, and Windows. It supports:
/// - Immediate notifications (for testing)
/// - Scheduled one-time notifications
/// - Weekly recurring notifications (perfect for class alarms!)
///
/// The key concept is **notification channels** (Android 8+): each channel
/// has its own importance level, sound, and vibration settings. Users can
/// control each channel independently in system settings.
///
/// We use the `timezone` package to calculate exact UTC times for weekly
/// recurring alarms, ensuring they fire at the correct local time even
/// across DST changes (less relevant for BD, but good practice).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification system. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database
    tzdata.initializeTimeZones();
    // Set local timezone to Dhaka (Bangladesh Standard Time, UTC+6)
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Combined initialization
    const initSettings = InitializationSettings(
      android: androidSettings,
      // iOS, macOS, etc. can be added here
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Called when a user taps a notification.
  void _onNotificationTapped(NotificationResponse response) {
    // Future: navigate to the specific class detail screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  // --- Android Notification Channel ---

  /// The notification details used for class reminders.
  NotificationDetails get _classReminderDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'class_reminders',
        'Class Reminders',
        channelDescription: 'Notifications for upcoming class sessions',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        // Use default alarm sound
      ),
    );
  }

  // --- Scheduling ---

  /// Schedules a weekly recurring notification for a class session.
  ///
  /// The notification fires [leadMinutes] before the class starts,
  /// on the same day-of-week every week.
  Future<void> scheduleWeeklyClassAlarm(
    ClassSession session, {
    int leadMinutes = 15,
  }) async {
    if (!session.isNotificationEnabled) return;

    final notificationId = _notificationId(session.id);

    // Calculate the alarm time (class start minus lead minutes)
    final alarmHour = session.startHour;
    final alarmMinute = session.startMinute - leadMinutes;

    // Handle minute underflow (e.g., 09:00 - 15min = 08:45)
    int adjustedHour = alarmHour;
    int adjustedMinute = alarmMinute;
    if (adjustedMinute < 0) {
      adjustedHour -= 1;
      adjustedMinute += 60;
    }


    // Build the notification content
    final title = '📚 ${session.courseCode} (${session.section})';
    final body =
        'Starting in $leadMinutes min • ${session.fullRoom}'
        '${session.group != null ? ' • ${session.group}' : ''}';

    // Calculate the next occurrence of this day/time
    final scheduledDate = _nextInstanceOfDayAndTime(
      session.dayOfWeek,
      adjustedHour,
      adjustedMinute,
    );

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _classReminderDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: session.id,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Cancels the notification for a specific class session.
  Future<void> cancelClassAlarm(String sessionId) async {
    await _plugin.cancel(id: _notificationId(sessionId));
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedules notifications for all enabled sessions.
  Future<void> rescheduleAll(
    List<ClassSession> sessions, {
    int leadMinutes = 15,
  }) async {
    await cancelAll();
    for (final session in sessions) {
      await scheduleWeeklyClassAlarm(session, leadMinutes: leadMinutes);
    }
  }

  /// Sends an immediate test notification to verify the notification engine.
  Future<void> sendTestNotification() async {
    await _plugin.show(
      id: 0,
      title: '🔔 Test Notification',
      body: 'Class Routine Notifier is working! You will receive alerts before your classes.',
      notificationDetails: _classReminderDetails,
    );
  }

  // --- Helpers ---

  /// Generates a stable notification ID from a session UUID string.
  /// Uses hashCode, clamped to a safe 32-bit integer range.
  int _notificationId(String sessionId) {
    return sessionId.hashCode & 0x7FFFFFFF; // Ensure positive 32-bit int
  }


  /// Calculates the next occurrence of a specific day-of-week and time
  /// as a timezone-aware DateTime.
  tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Move to the correct day of week
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // If this time already passed today, move to next week
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }
}
