import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/core/utils/time_utils.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';

void main() {
  group('TimeUtils Unit Tests', () {
    test('parseTimeString with various valid 24h formats', () {
      final t1 = TimeUtils.parseTimeString('09:00');
      expect(t1?.hour, 9);
      expect(t1?.minute, 0);

      final t2 = TimeUtils.parseTimeString('14:15');
      expect(t2?.hour, 14);
      expect(t2?.minute, 15);

      final t3 = TimeUtils.parseTimeString('23:59');
      expect(t3?.hour, 23);
      expect(t3?.minute, 59);
    });

    test('parseTimeString with 12h AM/PM formats', () {
      final t1 = TimeUtils.parseTimeString('9:30 AM');
      expect(t1?.hour, 9);
      expect(t1?.minute, 30);

      final t2 = TimeUtils.parseTimeString('12:00 PM');
      expect(t2?.hour, 12);
      expect(t2?.minute, 0);

      final t3 = TimeUtils.parseTimeString('12:30 AM');
      expect(t3?.hour, 0);
      expect(t3?.minute, 30);

      final t4 = TimeUtils.parseTimeString('2:15 PM');
      expect(t4?.hour, 14);
      expect(t4?.minute, 15);
    });

    test('parseTimeString with invalid inputs returns null', () {
      expect(TimeUtils.parseTimeString(''), isNull);
      expect(TimeUtils.parseTimeString('invalid'), isNull);
      expect(TimeUtils.parseTimeString('25:00'), isNull);
      expect(TimeUtils.parseTimeString('12:61'), isNull);
    });

    test('formatTime produces correct 24-hour display strings', () {
      expect(TimeUtils.formatTime(9, 5), '09:05');
      expect(TimeUtils.formatTime(14, 15), '14:15');
    });

    test('formatTime12h produces correct 12-hour display strings', () {
      expect(TimeUtils.formatTime12h(9, 0), '9:00 AM');
      expect(TimeUtils.formatTime12h(12, 0), '12:00 PM');
      expect(TimeUtils.formatTime12h(14, 15), '2:15 PM');
      expect(TimeUtils.formatTime12h(0, 30), '12:30 AM');
    });

    test('getDayName and getDayNameShort', () {
      expect(TimeUtils.getDayName(6), 'Saturday');
      expect(TimeUtils.getDayNameShort(6), 'Sat');
      expect(TimeUtils.getDayName(7), 'Sunday');
      expect(TimeUtils.getDayNameShort(7), 'Sun');
      expect(TimeUtils.getDayName(1), 'Monday');
      expect(TimeUtils.getDayNameShort(1), 'Mon');
      expect(TimeUtils.getDayName(2), 'Tuesday');
      expect(TimeUtils.getDayNameShort(2), 'Tue');
      expect(TimeUtils.getDayName(3), 'Wednesday');
      expect(TimeUtils.getDayNameShort(3), 'Wed');
      expect(TimeUtils.getDayName(4), 'Thursday');
      expect(TimeUtils.getDayNameShort(4), 'Thu');
      expect(TimeUtils.getDayName(5), 'Friday');
      expect(TimeUtils.getDayNameShort(5), 'Fri');
      expect(TimeUtils.getDayName(99), 'Unknown');
      expect(TimeUtils.getDayNameShort(99), '??');
    });

    test('dayNameToWeekday handles full and abbreviated day names', () {
      expect(TimeUtils.dayNameToWeekday('Saturday'), 6);
      expect(TimeUtils.dayNameToWeekday('sat'), 6);
      expect(TimeUtils.dayNameToWeekday('Sunday'), 7);
      expect(TimeUtils.dayNameToWeekday('sun'), 7);
      expect(TimeUtils.dayNameToWeekday('Monday'), 1);
      expect(TimeUtils.dayNameToWeekday('mon'), 1);
      expect(TimeUtils.dayNameToWeekday('Tuesday'), 2);
      expect(TimeUtils.dayNameToWeekday('tue'), 2);
      expect(TimeUtils.dayNameToWeekday('Wednesday'), 3);
      expect(TimeUtils.dayNameToWeekday('wed'), 3);
      expect(TimeUtils.dayNameToWeekday('Thursday'), 4);
      expect(TimeUtils.dayNameToWeekday('thu'), 4);
      expect(TimeUtils.dayNameToWeekday('Friday'), 5);
      expect(TimeUtils.dayNameToWeekday('fri'), 5);
      expect(TimeUtils.dayNameToWeekday('invalid_day'), isNull);
    });

    test('sortByTime sorts sessions chronologically', () {
      final s1 = ClassSession.create(
        courseCode: 'LATE',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 1,
        startHour: 14,
        startMinute: 15,
        endHour: 15,
        endMinute: 30,
      );
      final s2 = ClassSession.create(
        courseCode: 'EARLY',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 1,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      final s3 = ClassSession.create(
        courseCode: 'MID',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 1,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      );

      final sorted = TimeUtils.sortByTime([s1, s2, s3]);
      expect(sorted[0].courseCode, 'EARLY');
      expect(sorted[1].courseCode, 'MID');
      expect(sorted[2].courseCode, 'LATE');
    });

    test('greeting returns non-empty friendly string', () {
      final greeting = TimeUtils.greeting();
      expect(greeting.startsWith('Good '), true);
    });

    test('timeUntilNext generates valid string for today and future days', () {
      final now = DateTime.now();

      // Today session in the future
      final futureToday = ClassSession.create(
        courseCode: 'TEST',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: now.weekday,
        startHour: (now.hour + 2) % 24,
        startMinute: now.minute,
        endHour: (now.hour + 3) % 24,
        endMinute: now.minute,
      );

      final countdown = TimeUtils.timeUntilNext(futureToday);
      expect(countdown.isNotEmpty, true);
    });
  });
}
