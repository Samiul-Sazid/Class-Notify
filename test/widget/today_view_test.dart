import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:class_routine_notifier/core/services/storage_service.dart';
import 'package:class_routine_notifier/core/services/notification_service.dart';
import 'package:class_routine_notifier/data/repositories/routine_repository.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';
import 'package:class_routine_notifier/ui/features/today/view_models/today_view_model.dart';
import 'package:class_routine_notifier/ui/features/today/views/today_view.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<void> scheduleWeeklyClassAlarm(ClassSession session, {int leadMinutes = 15}) async {}
  @override
  Future<void> cancelClassAlarm(String sessionId) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> rescheduleAll(List<ClassSession> sessions, {int leadMinutes = 15}) async {}
  @override
  Future<void> sendTestNotification() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late FakeNotificationService notificationService;
  late RoutineRepository repository;
  late TodayViewModel viewModel;

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
    viewModel = TodayViewModel(repository: repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  testWidgets('TodayView renders empty state when no classes exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodayView(viewModel: viewModel),
        ),
      ),
    );

    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('No Routine Yet'), findsOneWidget);
    expect(find.textContaining('Upload a photo'), findsOneWidget);
  });

  testWidgets('TodayView renders classes when present for today', (tester) async {
    final now = DateTime.now();
    final todaySession = ClassSession.create(
      courseCode: 'CSE 211',
      section: 'SCD',
      roomType: 'Lecture Room',
      roomNumber: '1002',
      dayOfWeek: now.weekday,
      startHour: 10,
      startMinute: 15,
      endHour: 11,
      endMinute: 30,
    );

    await repository.addSession(todaySession);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodayView(viewModel: viewModel),
        ),
      ),
    );

    expect(find.text('CSE 211'), findsWidgets);
    expect(find.text('SCD'), findsWidgets);
  });
}
