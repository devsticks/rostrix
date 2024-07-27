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

    expect(find.text('Doctors\' Overtime Call Roster'), findsOneWidget);
    expect(find.byType(RosterDisplay), findsOneWidget,
        reason: 'RosterDisplay widget not found');
    expect(find.byType(DoctorsSummaryTable), findsOneWidget,
        reason: 'DoctorsSummaryTable widget not found');
    expect(find.byType(LeaveManagement), findsOneWidget,
        reason: 'LeaveManagement widget not found');
  });

  // Add more widget tests as needed
}
