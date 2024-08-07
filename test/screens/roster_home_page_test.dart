import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rostrix/screens/roster_home_page.dart';
import 'package:rostrix/widgets/roster_display.dart';
import 'package:rostrix/widgets/doctors_summary_table.dart';
import 'package:rostrix/widgets/leave_management.dart';

void main() {
  testWidgets('Roster Home Page renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RosterHomePage()));

    expect(find.text('Rostrix'), findsOneWidget);
    expect(find.byType(RosterDisplay), findsOneWidget,
        reason: 'RosterDisplay widget not found');
  });

  // Add more widget tests as needed
}
