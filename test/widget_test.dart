// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:android_dashboard/main.dart';
import 'package:android_dashboard/dashboard_screen.dart';

void main() {
  testWidgets('Car Dashboard app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CarDashboardApp());

    // Verify that our app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
