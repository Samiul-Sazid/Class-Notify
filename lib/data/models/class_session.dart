import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Represents a single class session in the student's weekly routine.
///
/// Each session maps directly to one cell in a university timetable.
/// For example, "PROG 302 (MM) G-1 / Lab Room-2701" becomes:
///   courseCode = "PROG 302"
///   section    = "MM"
///   group      = "G-1"
///   roomType   = "Lab Room"
///   roomNumber = "2701"
///
/// ## Flutter Learning Note:
/// This is an **immutable data class**. In Flutter, we prefer immutable models
/// because they make state management predictable — you always create a new
/// instance instead of mutating the old one. The `copyWith` method is the
/// standard pattern for creating modified copies.
class ClassSession {
  final String id;
  final String courseCode;
  final String section;
  final String? group;
  final String? instructor;
  final String roomType;
  final String roomNumber;

  /// Day of week as Dart's DateTime weekday constant:
  /// 1 = Monday, 2 = Tuesday, ... 6 = Saturday, 7 = Sunday
  final int dayOfWeek;

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  /// ARGB color value for visual distinction in the UI.
  final int colorValue;

  /// Whether notifications/alarms are enabled for this specific class.
  final bool isNotificationEnabled;

  /// Optional note (e.g., "Including 15 mins prayer break", "Bring lab coat").
  final String? note;

  const ClassSession({
    required this.id,
    required this.courseCode,
    required this.section,
    this.group,
    this.instructor,
    required this.roomType,
    required this.roomNumber,
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorValue,
    this.isNotificationEnabled = true,
    this.note,
  });

  /// Creates a new ClassSession with a generated UUID.
  factory ClassSession.create({
    required String courseCode,
    required String section,
    String? group,
    String? instructor,
    required String roomType,
    required String roomNumber,
    required int dayOfWeek,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    int? colorValue,
    bool isNotificationEnabled = true,
    String? note,
  }) {
    return ClassSession(
      id: const Uuid().v4(),
      courseCode: courseCode,
      section: section,
      group: group,
      instructor: instructor,
      roomType: roomType,
      roomNumber: roomNumber,
      dayOfWeek: dayOfWeek,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      colorValue: colorValue ?? _autoColor(courseCode),
      isNotificationEnabled: isNotificationEnabled,
      note: note,
    );
  }

  // --- Convenience Getters ---

  /// Returns Flutter's TimeOfDay for the start time.
  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);

  /// Returns Flutter's TimeOfDay for the end time.
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  /// Formatted time range string, e.g. "09:00 - 10:15".
  String get timeRange {
    String fmt(int h, int m) =>
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    return '${fmt(startHour, startMinute)} - ${fmt(endHour, endMinute)}';
  }

  /// Full room display string, e.g. "Lab Room-2701".
  String get fullRoom {
    if (roomType.isEmpty) return roomNumber;
    if (roomNumber.isEmpty) return roomType;
    return '$roomType-$roomNumber';
  }

  /// Display name including section, e.g. "PROG 302 (MM)".
  String get displayName {
    final parts = [courseCode];
    if (section.isNotEmpty) parts.add('($section)');
    if (group != null) parts.add(group!);
    return parts.join(' ');
  }

  /// Duration in minutes.
  int get durationMinutes {
    return (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
  }

  /// The Color object derived from colorValue.
  Color get color => Color(colorValue);

  // --- Serialization ---

  /// Flutter Learning Note:
  /// `toJson` and `fromJson` are the standard pattern for converting Dart
  /// objects to and from JSON (`Map<String, dynamic>`). This is essential for
  /// persisting data with SharedPreferences or sending data over HTTP.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'section': section,
      'group': group,
      'instructor': instructor,
      'roomType': roomType,
      'roomNumber': roomNumber,
      'dayOfWeek': dayOfWeek,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'colorValue': colorValue,
      'isNotificationEnabled': isNotificationEnabled,
      'note': note,
    };
  }

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] as String,
      courseCode: json['courseCode'] as String,
      section: json['section'] as String? ?? '',
      group: json['group'] as String?,
      instructor: json['instructor'] as String?,
      roomType: json['roomType'] as String? ?? 'Lecture Room',
      roomNumber: json['roomNumber'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int,
      colorValue: json['colorValue'] as int? ?? 0xFF6C63FF,
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
      note: json['note'] as String?,
    );
  }

  // --- Copy With ---

  /// Creates a copy of this session with some fields replaced.
  /// This is the immutable update pattern used throughout Flutter.
  ClassSession copyWith({
    String? id,
    String? courseCode,
    String? section,
    String? group,
    String? instructor,
    String? roomType,
    String? roomNumber,
    int? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? colorValue,
    bool? isNotificationEnabled,
    String? note,
  }) {
    return ClassSession(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      section: section ?? this.section,
      group: group ?? this.group,
      instructor: instructor ?? this.instructor,
      roomType: roomType ?? this.roomType,
      roomNumber: roomNumber ?? this.roomNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      colorValue: colorValue ?? this.colorValue,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      note: note ?? this.note,
    );
  }

  /// Auto-assigns a color based on the course code prefix.
  static int _autoColor(String courseCode) {
    final prefix = courseCode.split(' ').first.toUpperCase();
    const colorMap = {
      'PROG': 0xFF7C4DFF, // Deep purple
      'IRE': 0xFF00BCD4, // Cyan
      'CSE': 0xFFFF7043, // Deep orange
      'MATH': 0xFF66BB6A, // Green
      'PHY': 0xFFFFCA28, // Amber
      'EEE': 0xFFEF5350, // Red
      'ENG': 0xFF42A5F5, // Blue
      'BBA': 0xFFAB47BC, // Purple
      'LAW': 0xFF8D6E63, // Brown
    };
    return colorMap[prefix] ?? (courseCode.hashCode | 0xFF000000);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClassSession && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ClassSession($displayName, day=$dayOfWeek, $timeRange)';
}
