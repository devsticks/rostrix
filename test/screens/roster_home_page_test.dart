import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rostrem/screens/roster_home_page.dart';
import 'package:rostrem/widgets/roster_display.dart';
import 'package:rostrem/widgets/doctors_summary_table.dart';
import 'package:rostrem/widgets/leave_management.dart';

void main() {
  testWidgets('Roster Home Page renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RosterHomePage()));

    expect(find.text('Doctors Overtime Call Roster'), findsOneWidget);
    expect(find.byType(RosterDisplay), findsOneWidget);
    expect(find.byType(DoctorsSummaryTable), findsOneWidget);
    expect(find.byType(LeaveManagement), findsOneWidget);
  });

  // Add more widget tests as needed
}
