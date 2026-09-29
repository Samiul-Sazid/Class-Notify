import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/data/models/class_session.dart';
import 'package:class_routine_notifier/ui/core/class_session_card.dart';

void main() {
  testWidgets('ClassSessionCard renders course code, section, and room details', (tester) async {
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
      note: 'Special Note',
    );

    bool tapped = false;
    bool notificationToggled = false;
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClassSessionCard(
            session: session,
            onTap: () => tapped = true,
            onToggleNotification: () => notificationToggled = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    // Verify course code
    expect(find.text('PROG 302'), findsOneWidget);

    // Verify section badge
    expect(find.text('MM'), findsOneWidget);

    // Verify group badge
    expect(find.text('G-1'), findsOneWidget);

    // Verify time range
    expect(find.text('10:15 - 11:30'), findsOneWidget);

    // Verify note
    expect(find.text('Special Note'), findsOneWidget);

    // Test tap
    await tester.tap(find.text('PROG 302'));
    expect(tapped, true);

    // Test notification icon toggle
    final notifFinder = find.byIcon(Icons.notifications_active_rounded);
    expect(notifFinder, findsOneWidget);
    await tester.tap(notifFinder);
    expect(notificationToggled, true);

    // Test swipe dismissal
    await tester.drag(find.text('PROG 302'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deleted, true);
  });
}
