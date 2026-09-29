/// Pre-defined time slot definitions matching university routine column headers.
///
/// These represent the standard 75-minute academic time blocks.
/// For example, the user's routine has:
///   Slot 1: 09:00 - 10:15
///   Slot 2: 10:15 - 11:30
///   Slot 3: 11:30 - 12:45
///   Slot 4: 12:45 - 14:15 (with 15 min prayer break)
///   Slot 5: 14:15 - 15:30
///
/// ## Flutter Learning Note:
/// This is a simple value object — no mutable state, just data + factory
/// constants. Using `const` constructors lets Dart optimize memory by
/// reusing the same instance whenever identical values are used.
class RoutineSlot {
  final String label;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String? note;

  const RoutineSlot({
    required this.label,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.note,
  });

  /// Default 75-minute slot grid matching Bangladeshi university schedules.
  static const List<RoutineSlot> defaultSlots = [
    RoutineSlot(
      label: 'Slot 1',
      startHour: 9,
      startMinute: 0,
      endHour: 10,
      endMinute: 15,
    ),
    RoutineSlot(
      label: 'Slot 2',
      startHour: 10,
      startMinute: 15,
      endHour: 11,
      endMinute: 30,
    ),
    RoutineSlot(
      label: 'Slot 3',
      startHour: 11,
      startMinute: 30,
      endHour: 12,
      endMinute: 45,
    ),
    RoutineSlot(
      label: 'Slot 4',
      startHour: 12,
      startMinute: 45,
      endHour: 14,
      endMinute: 15,
      note: 'Including 15 mins prayer break',
    ),
    RoutineSlot(
      label: 'Slot 5',
      startHour: 14,
      startMinute: 15,
      endHour: 15,
      endMinute: 30,
    ),
  ];

  /// Formatted start time string, e.g. "09:00".
  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  /// Formatted end time string, e.g. "10:15".
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  /// Full time range display, e.g. "09:00 - 10:15".
  String get timeRange => '$startTimeFormatted - $endTimeFormatted';

  @override
  String toString() => 'RoutineSlot($label: $timeRange)';
}
