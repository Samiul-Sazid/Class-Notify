import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:class_routine_notifier/core/services/storage_service.dart';
import 'package:class_routine_notifier/core/services/notification_service.dart';
import 'package:class_routine_notifier/data/repositories/routine_repository.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';

class FakeNotificationService implements NotificationService {
  final List<String> scheduledSessionIds = [];
  final List<String> cancelledSessionIds = [];
  bool cancelledAll = false;
  int testNotificationsSent = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleWeeklyClassAlarm(ClassSession session, {int leadMinutes = 15}) async {
    scheduledSessionIds.add(session.id);
  }

  @override
  Future<void> cancelClassAlarm(String sessionId) async {
    cancelledSessionIds.add(sessionId);
  }

  @override
  Future<void> cancelAll() async {
    cancelledAll = true;
    scheduledSessionIds.clear();
  }

  @override
  Future<void> rescheduleAll(List<ClassSession> sessions, {int leadMinutes = 15}) async {
    scheduledSessionIds.clear();
    for (final s in sessions) {
      if (s.isNotificationEnabled) {
        scheduledSessionIds.add(s.id);
      }
    }
  }

  @override
  Future<void> sendTestNotification() async {
    testNotificationsSent++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late FakeNotificationService notificationService;
  late RoutineRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();

    notificationService = FakeNotificationService();
    repository = RoutineRepository(
      storage: storageService,
      notifications: notificationService,
    );
    await repository.init();
  });

  group('RoutineRepository Tests', () {
    test('initial state is empty with default settings', () {
      expect(repository.allSessions, isEmpty);
      expect(repository.settings.reminderLeadMinutes, 15);
      expect(repository.hasClasses, false);
    });

    test('addSession adds session and syncs notifications', () async {
      final session = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: 'Lab',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );

      await repository.addSession(session);

      expect(repository.allSessions.length, 1);
      expect(repository.allSessions.first.courseCode, 'PROG 302');
      expect(notificationService.scheduledSessionIds, contains(session.id));
    });

    test('updateSession modifies existing session and persists', () async {
      final session = ClassSession.create(
        courseCode: 'PROG 302',
        section: 'MM',
        roomType: 'Lab',
        roomNumber: '2701',
        dayOfWeek: 6,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );
      await repository.addSession(session);

      final updated = session.copyWith(roomNumber: '3001');
      await repository.updateSession(updated);

      expect(repository.allSessions.first.roomNumber, '3001');
    });

    test('deleteSession removes session and cancels alarm', () async {
      final session = ClassSession.create(
        courseCode: 'MATH 217',
        section: '',
        roomType: 'Lecture',
        roomNumber: '1001',
        dayOfWeek: 7,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      await repository.addSession(session);
      expect(repository.allSessions.length, 1);

      await repository.deleteSession(session.id);
      expect(repository.allSessions, isEmpty);
      expect(notificationService.cancelledSessionIds, contains(session.id));
    });

    test('toggleNotification changes state and reschedules', () async {
      final session = ClassSession.create(
        courseCode: 'CSE 211',
        section: 'A',
        roomType: 'Lecture',
        roomNumber: '1002',
        dayOfWeek: 1,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
        isNotificationEnabled: true,
      );
      await repository.addSession(session);

      await repository.toggleNotification(session.id);
      expect(repository.allSessions.first.isNotificationEnabled, false);
      expect(notificationService.scheduledSessionIds, isNot(contains(session.id)));

      await repository.toggleNotification(session.id);
      expect(repository.allSessions.first.isNotificationEnabled, true);
      expect(notificationService.scheduledSessionIds, contains(session.id));
    });

    test('importSessions batch imports with clearExisting flag', () async {
      final s1 = ClassSession.create(
        courseCode: 'C1',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 6,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      await repository.addSession(s1);

      final s2 = ClassSession.create(
        courseCode: 'C2',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 7,
        startHour: 10,
        startMinute: 15,
        endHour: 11,
        endMinute: 30,
      );
      final s3 = ClassSession.create(
        courseCode: 'C3',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 1,
        startHour: 11,
        startMinute: 30,
        endHour: 12,
        endMinute: 45,
      );

      // Import with clearExisting = true
      await repository.importSessions([s2, s3], clearExisting: true);

      expect(repository.allSessions.length, 2);
      expect(repository.allSessions.any((s) => s.courseCode == 'C1'), false);
      expect(repository.allSessions.any((s) => s.courseCode == 'C2'), true);
      expect(repository.allSessions.any((s) => s.courseCode == 'C3'), true);
    });

    test('getSessionsForDay returns sorted sessions for that day', () async {
      final s1 = ClassSession.create(
        courseCode: 'LATER',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 6,
        startHour: 12,
        startMinute: 45,
        endHour: 14,
        endMinute: 15,
      );
      final s2 = ClassSession.create(
        courseCode: 'EARLIER',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 6,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );
      final s3 = ClassSession.create(
        courseCode: 'OTHER_DAY',
        section: '',
        roomType: '',
        roomNumber: '',
        dayOfWeek: 7,
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 15,
      );

      await repository.importSessions([s1, s2, s3]);

      final sat = repository.getSessionsForDay(6);
      expect(sat.length, 2);
      expect(sat[0].courseCode, 'EARLIER');
      expect(sat[1].courseCode, 'LATER');
    });

    test('dayClassCounts maps day numbers to class count', () async {
      final s1 = ClassSession.create(
        courseCode: 'S1', section: '', roomType: '', roomNumber: '',
        dayOfWeek: 6, startHour: 9, startMinute: 0, endHour: 10, endMinute: 0,
      );
      final s2 = ClassSession.create(
        courseCode: 'S2', section: '', roomType: '', roomNumber: '',
        dayOfWeek: 6, startHour: 10, startMinute: 0, endHour: 11, endMinute: 0,
      );
      final s3 = ClassSession.create(
        courseCode: 'S3', section: '', roomType: '', roomNumber: '',
        dayOfWeek: 7, startHour: 9, startMinute: 0, endHour: 10, endMinute: 0,
      );

      await repository.importSessions([s1, s2, s3]);
      final counts = repository.dayClassCounts;
      expect(counts[6], 2);
      expect(counts[7], 1);
      expect(counts[1], isNull);
    });

    test('clearAll wipes sessions and settings data', () async {
      final session = ClassSession.create(
        courseCode: 'TEST', section: '', roomType: '', roomNumber: '',
        dayOfWeek: 6, startHour: 9, startMinute: 0, endHour: 10, endMinute: 0,
      );
      await repository.addSession(session);
      expect(repository.allSessions.length, 1);

      await repository.clearAll();
      expect(repository.allSessions, isEmpty);
      expect(notificationService.cancelledAll, true);
    });

    test('updateSettings updates state and triggers reschedule on lead change', () async {
      final session = ClassSession.create(
        courseCode: 'TEST', section: '', roomType: '', roomNumber: '',
        dayOfWeek: 6, startHour: 9, startMinute: 0, endHour: 10, endMinute: 0,
      );
      await repository.addSession(session);

      await repository.updateSettings(
        repository.settings.copyWith(reminderLeadMinutes: 30),
      );

      expect(repository.settings.reminderLeadMinutes, 30);
      expect(notificationService.scheduledSessionIds, contains(session.id));
    });
  });
}
