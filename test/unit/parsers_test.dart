import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/domain/services/sample_routine_parser.dart';

void main() {
  group('SampleRoutineParser Tests', () {
    test('extracts all sample classes accurately', () async {
      final parser = SampleRoutineParser();
      final sessions = await parser.parseRoutineImage('dummy_path');

      expect(sessions.isNotEmpty, true);
      expect(sessions.length, 16);

      // Verify Saturday sessions (weekday 6)
      final satSessions = sessions.where((s) => s.dayOfWeek == 6).toList();
      expect(satSessions.length, 3);
      expect(satSessions[0].courseCode, 'PROG 302');
      expect(satSessions[0].group, 'G-1');
      expect(satSessions[0].roomNumber, '2701');
      expect(satSessions[1].courseCode, 'PROG 302');
      expect(satSessions[1].group, 'G-2');
      expect(satSessions[2].courseCode, 'PROG 301');
      expect(satSessions[2].note, contains('prayer'));

      // Verify Sunday sessions (weekday 7)
      final sunSessions = sessions.where((s) => s.dayOfWeek == 7).toList();
      expect(sunSessions.length, 6);
      expect(sunSessions.any((s) => s.courseCode == 'MATH 217' && s.instructor == 'Sujan Sir'), true);

      // Verify Monday sessions (weekday 1)
      final monSessions = sessions.where((s) => s.dayOfWeek == 1).toList();
      expect(monSessions.length, 4);

      // Verify Tuesday sessions (weekday 2)
      final tueSessions = sessions.where((s) => s.dayOfWeek == 2).toList();
      expect(tueSessions.length, 3);
    });
  });
}
