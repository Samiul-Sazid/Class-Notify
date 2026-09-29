// This is a basic widget test placeholder.
//
// Full unit tests for ClassSession, TimeUtils, and RoutineRepository
// will be added as the project matures.
//
// To run this test: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';
import 'package:class_routine_notifier/core/utils/time_utils.dart';

void main() {
  group('ClassSession', () {
    test('JSON round-trip serialization', () {
      final session = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        group: 'G-1',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
        note: 'Including 15 mins prayer break',
      );

      final json = session.toJson();
      final restored = ClassSession.fromJson(json);

      expect(restored.courseCode, 'PROG 302');
      expect(restored.section, 'MM');
      expect(restored.group, 'G-1');
      expect(restored.roomType, 'Lab Room');
      expect(restored.roomNumber, '2701');
      expect(restored.dayOfWeek, 6);
      expect(restored.startHour, 10);
      expect(restored.startMinute, 15);
      expect(restored.endHour, 11);
      expect(restored.endMinute, 30);
      expect(restored.note, 'Including 15 mins prayer break');
      expect(restored.isNotificationEnabled, true);
    });

    test('displayName formats correctly', () {
      final session = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        group: 'G-1',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );

      expect(session.displayName, 'PROG 302 (MM) G-1');
    });

    test('timeRange formats correctly', () {
      final session = ClassSession.create(
        courseCode: 'CSE 219',
        section: 'MTA',
        roomType: 'Lecture Room',
        roomNumber: '4002',
        dayOfWeek: 1,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );

      expect(session.timeRange, '10:15 - 11:30');
    });

    test('durationMinutes calculates correctly', () {
      final session = ClassSession.create(
        courseCode: 'IRE 215',
        section: 'SE',
        roomType: 'Lecture Room',
        roomNumber: '1002',
        dayOfWeek: 7,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );

      expect(session.durationMinutes, 75);
    });

    test('copyWith preserves unchanged fields', () {
      final original = ClassSession.create(
        courseCode: 'MATH 217',
        section: '',
        instructor: 'Sujan Sir',
        roomType: 'Lecture Room',
        roomNumber: '2002',
        dayOfWeek: 7,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      );

      final updated = original.copyWith(roomNumber: '3003');

      expect(updated.courseCode, 'MATH 217');
      expect(updated.instructor, 'Sujan Sir');
      expect(updated.roomNumber, '3003');
      expect(updated.id, original.id); // Same ID
    });
  });

  group('TimeUtils', () {
    test('parseTimeString handles 24-hour format', () {
      final time = TimeUtils.parseTimeString('14:15');
      expect(time?.hour, 14);
      expect(time?.minute, 15);
    });

    test('parseTimeString handles 12-hour AM/PM format', () {
      final time = TimeUtils.parseTimeString('10:30 AM');
      expect(time?.hour, 10);
      expect(time?.minute, 30);

      final pmTime = TimeUtils.parseTimeString('2:15 PM');
      expect(pmTime?.hour, 14);
      expect(pmTime?.minute, 15);
    });

    test('getDayName returns correct names', () {
      expect(TimeUtils.getDayName(1), 'Monday');
      expect(TimeUtils.getDayName(6), 'Saturday');
      expect(TimeUtils.getDayName(7), 'Sunday');
    });

    test('dayNameToWeekday converts correctly', () {
      expect(TimeUtils.dayNameToWeekday('Saturday'), 6);
      expect(TimeUtils.dayNameToWeekday('Sunday'), 7);
      expect(TimeUtils.dayNameToWeekday('Monday'), 1);
      expect(TimeUtils.dayNameToWeekday('Tue'), 2);
    });

    test('sortByTime orders sessions correctly', () {
      final sessions = [
        ClassSession.create(
          courseCode: 'B', section: '', roomType: '', roomNumber: '',
          dayOfWeek: 1, startHour: 11, startMinute: 30, endHour: 12, endMinute: 45,
        ),
        ClassSession.create(
          courseCode: 'A', section: '', roomType: '', roomNumber: '',
          dayOfWeek: 1, startHour: 9, startMinute: 0, endHour: 10, endMinute: 15,
        ),
      ];

      final sorted = TimeUtils.sortByTime(sessions);
      expect(sorted[0].courseCode, 'A');
      expect(sorted[1].courseCode, 'B');
    });
  });
}
