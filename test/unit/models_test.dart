import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';
import 'package:class_routine_notifier/data/models/routine_slot.dart';
import 'package:class_routine_notifier/data/models/user_settings.dart';

void main() {
  group('ClassSession Model Tests', () {
    test('create factory generates unique id and default color', () {
      final session1 = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );

      final session2 = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );

      expect(session1.id.isNotEmpty, true);
      expect(session2.id.isNotEmpty, true);
      expect(session1.id, isNot(equals(session2.id)));
      expect(session1.isNotificationEnabled, true);
    });

    test('displayName with and without group or instructor', () {
      final s1 = ClassSession.create(
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
      expect(s1.displayName, 'PROG 302 (MM) G-1');

      final s2 = ClassSession.create(
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
      expect(s2.displayName, 'MATH 217');

      final s3 = ClassSession.create(
        courseCode: 'CSE 101',
        section: 'A',
        roomType: 'Lecture Room',
        roomNumber: '101',
        dayOfWeek: 1,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      expect(s3.displayName, 'CSE 101 (A)');
    });

    test('fullRoom formatting', () {
      final s1 = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: 'Lab Room',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );
      expect(s1.fullRoom, 'Lab Room-2701');

      final s2 = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: '',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );
      expect(s2.fullRoom, '2701');
    });

    test('timeRange formats start and end times with leading zeros', () {
      final s = ClassSession.create(
        courseCode: 'TEST 101',
        section: 'A',
        roomType: 'Lecture',
        roomNumber: '101',
        dayOfWeek: 1,
        startHour: 9,
        startMinute: 5,
        endHour: 10,
        endMinute: 20,
      );
      expect(s.timeRange, '09:05 - 10:20');
    });

    test('durationMinutes accurately calculates session length', () {
      final s = ClassSession.create(
        courseCode: 'TEST 101',
        section: 'A',
        roomType: 'Lecture',
        roomNumber: '101',
        dayOfWeek: 1,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
      );
      expect(s.durationMinutes, 90);
    });

    test('JSON serialization round-trip', () {
      final original = ClassSession.create(
        courseCode: 'CSE 219',
        section: 'MTA',
        group: 'G-2',
        instructor: 'Dr. John',
        roomType: 'Lecture Room',
        roomNumber: '4002',
        dayOfWeek: 2,
        startHour: 14,
        startMinute: 15,
        endHour: 15,
        endMinute: 30,
        colorValue: 0xFF123456,
        isNotificationEnabled: false,
        note: 'Bring assignments',
      );

      final json = original.toJson();
      final fromJson = ClassSession.fromJson(json);

      expect(fromJson.id, original.id);
      expect(fromJson.courseCode, original.courseCode);
      expect(fromJson.section, original.section);
      expect(fromJson.group, original.group);
      expect(fromJson.instructor, original.instructor);
      expect(fromJson.roomType, original.roomType);
      expect(fromJson.roomNumber, original.roomNumber);
      expect(fromJson.dayOfWeek, original.dayOfWeek);
      expect(fromJson.startHour, original.startHour);
      expect(fromJson.startMinute, original.startMinute);
      expect(fromJson.endHour, original.endHour);
      expect(fromJson.endMinute, original.endMinute);
      expect(fromJson.colorValue, original.colorValue);
      expect(fromJson.isNotificationEnabled, original.isNotificationEnabled);
      expect(fromJson.note, original.note);
    });

    test('copyWith updates only specified fields', () {
      final original = ClassSession.create(
        courseCode: 'MATH 217',
        section: 'S1',
        roomType: 'Lecture',
        roomNumber: '101',
        dayOfWeek: 6,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );

      final updated = original.copyWith(
        courseCode: 'MATH 218',
        isNotificationEnabled: false,
      );

      expect(updated.id, original.id);
      expect(updated.courseCode, 'MATH 218');
      expect(updated.section, 'S1');
      expect(updated.isNotificationEnabled, false);
      expect(updated.roomNumber, '101');
    });
  });

  group('RoutineSlot Model Tests', () {
    test('defaultSlots contains 5 standard university blocks', () {
      expect(RoutineSlot.defaultSlots.length, 5);
      expect(RoutineSlot.defaultSlots[0].startTimeFormatted, '09:00');
      expect(RoutineSlot.defaultSlots[0].endTimeFormatted, '10:15');
      expect(RoutineSlot.defaultSlots[0].timeRange, '09:00 - 10:15');
      expect(RoutineSlot.defaultSlots[3].note, contains('prayer'));
    });

    test('timeRange and toString output', () {
      const slot = RoutineSlot(
        label: 'Morning Slot',
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      expect(slot.timeRange, '09:00 - 10:15');
      expect(slot.toString(), contains('Morning Slot: 09:00 - 10:15'));
    });

    test('startHour, startMinute, endHour, endMinute values', () {
      final slot = RoutineSlot.defaultSlots[0];
      expect(slot.startHour, 9);
      expect(slot.startMinute, 0);
      expect(slot.endHour, 10);
      expect(slot.endMinute, 15);
    });
  });

  group('UserSettings Model Tests', () {
    test('default settings are correct', () {
      const settings = UserSettings();
      expect(settings.reminderLeadMinutes, 15);
      expect(settings.isSoundEnabled, true);
      expect(settings.isVibrateEnabled, true);
      expect(settings.geminiApiKey, isNull);
      expect(settings.isDarkMode, true);
      expect(settings.weekStartDay, 6); // Saturday for BD
    });

    test('orderedWeekDays starting Saturday (BD standard)', () {
      const settings = UserSettings(weekStartDay: 6);
      expect(settings.orderedWeekDays, [6, 7, 1, 2, 3, 4]); // Sat, Sun, Mon, Tue, Wed, Thu
    });

    test('orderedWeekDays starting Monday', () {
      const settings = UserSettings(weekStartDay: 1);
      expect(settings.orderedWeekDays, [1, 2, 3, 4, 5, 6, 7]);
    });

    test('JSON serialization round-trip', () {
      const settings = UserSettings(
        reminderLeadMinutes: 30,
        isSoundEnabled: false,
        isVibrateEnabled: true,
        geminiApiKey: 'test_key_123',
        isDarkMode: false,
        semesterLabel: 'Spring 2026',
        weekStartDay: 1,
      );

      final jsonString = settings.toJsonString();
      final restored = UserSettings.fromJsonString(jsonString);

      expect(restored.reminderLeadMinutes, 30);
      expect(restored.isSoundEnabled, false);
      expect(restored.isVibrateEnabled, true);
      expect(restored.geminiApiKey, 'test_key_123');
      expect(restored.isDarkMode, false);
      expect(restored.semesterLabel, 'Spring 2026');
      expect(restored.weekStartDay, 1);
    });

    test('copyWith updates specified fields only', () {
      const original = UserSettings();
      final updated = original.copyWith(
        geminiApiKey: 'new_key',
        reminderLeadMinutes: 10,
      );

      expect(updated.geminiApiKey, 'new_key');
      expect(updated.reminderLeadMinutes, 10);
      expect(updated.isDarkMode, original.isDarkMode);
      expect(updated.isSoundEnabled, original.isSoundEnabled);
    });
  });
}
