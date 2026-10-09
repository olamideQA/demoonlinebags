import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demoonlinebags/app.dart';

void main() {
  testWidgets('DemoOnlineBagsApp initial smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: DemoOnlineBagsApp(),
      ),
    );
    expect(find.byType(DemoOnlineBagsApp), findsOneWidget);
  });
}
