import 'dart:convert';

/// Stores the student's app preferences.
///
/// ## Flutter Learning Note:
/// This model follows the same immutable pattern as ClassSession.
/// Settings are serialized to JSON and stored in SharedPreferences.
/// The `copyWith` method lets the UI update individual settings without
/// affecting other values — very useful in Settings screens.
class UserSettings {
  /// Minutes before class to send reminder (5, 10, 15, 30).
  final int reminderLeadMinutes;

  /// Whether to play a sound with the notification.
  final bool isSoundEnabled;

  /// Whether to vibrate with the notification.
  final bool isVibrateEnabled;

  /// User's Gemini API key for AI routine parsing.
  final String? geminiApiKey;

  /// Whether dark mode is active.
  final bool isDarkMode;

  /// Label for the current semester/academic year, e.g. "2022-2023".
  final String semesterLabel;

  /// First day of the academic week (6 = Saturday for BD, 1 = Monday for others).
  final int weekStartDay;

  const UserSettings({
    this.reminderLeadMinutes = 15,
    this.isSoundEnabled = true,
    this.isVibrateEnabled = true,
    this.geminiApiKey,
    this.isDarkMode = true,
    this.semesterLabel = '',
    this.weekStartDay = 6, // Saturday default for Bangladesh
  });

  /// Returns the ordered list of day-of-week integers for the academic week.
  /// For BD: [6, 7, 1, 2, 3, 4] = Sat, Sun, Mon, Tue, Wed, Thu
  /// For western: [1, 2, 3, 4, 5] = Mon through Fri
  List<int> get orderedWeekDays {
    if (weekStartDay == 6) {
      return [6, 7, 1, 2, 3, 4]; // Sat - Thu
    } else {
      return [1, 2, 3, 4, 5, 6, 7]; // Mon - Sun
    }
  }

  // --- Serialization ---

  Map<String, dynamic> toJson() {
    return {
      'reminderLeadMinutes': reminderLeadMinutes,
      'isSoundEnabled': isSoundEnabled,
      'isVibrateEnabled': isVibrateEnabled,
      'geminiApiKey': geminiApiKey,
      'isDarkMode': isDarkMode,
      'semesterLabel': semesterLabel,
      'weekStartDay': weekStartDay,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      reminderLeadMinutes: json['reminderLeadMinutes'] as int? ?? 15,
      isSoundEnabled: json['isSoundEnabled'] as bool? ?? true,
      isVibrateEnabled: json['isVibrateEnabled'] as bool? ?? true,
      geminiApiKey: json['geminiApiKey'] as String?,
      isDarkMode: json['isDarkMode'] as bool? ?? true,
      semesterLabel: json['semesterLabel'] as String? ?? '',
      weekStartDay: json['weekStartDay'] as int? ?? 6,
    );
  }

  /// Convenience: serialize to a JSON string (for SharedPreferences).
  String toJsonString() => jsonEncode(toJson());

  /// Convenience: deserialize from a JSON string.
  factory UserSettings.fromJsonString(String jsonString) {
    return UserSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  // --- Copy With ---

  UserSettings copyWith({
    int? reminderLeadMinutes,
    bool? isSoundEnabled,
    bool? isVibrateEnabled,
    String? geminiApiKey,
    bool? isDarkMode,
    String? semesterLabel,
    int? weekStartDay,
  }) {
    return UserSettings(
      reminderLeadMinutes: reminderLeadMinutes ?? this.reminderLeadMinutes,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrateEnabled: isVibrateEnabled ?? this.isVibrateEnabled,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      semesterLabel: semesterLabel ?? this.semesterLabel,
      weekStartDay: weekStartDay ?? this.weekStartDay,
    );
  }
}
