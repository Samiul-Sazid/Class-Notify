import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:class_routine_notifier/ui/core/glass_card.dart';

void main() {
  testWidgets('GlassCard displays child content and respects onTap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassCard(
            onTap: () => tapped = true,
            child: const Text('Glass Content'),
          ),
        ),
      ),
    );

    expect(find.text('Glass Content'), findsOneWidget);

    await tester.tap(find.text('Glass Content'));
    expect(tapped, true);
  });
}
