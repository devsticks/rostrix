import 'package:flutter_test/flutter_test.dart';
import 'package:rostrem/models/roster.dart';
import 'package:rostrem/models/shift.dart';
import 'package:rostrem/models/doctor.dart';

void main() {
  group('Roster Model Tests', () {
    test('Roster can be instantiated and assigns shifts correctly', () {
      final doctors = [
        Doctor(
            name: 'Dr. A',
            canPerformCaesars: true,
            canPerformAnaesthetics: false),
        Doctor(
            name: 'Dr. B',
            canPerformCaesars: false,
            canPerformAnaesthetics: true),
        Doctor(
            name: 'Dr. C',
            canPerformCaesars: true,
            canPerformAnaesthetics: true),
        Doctor(
            name: 'Dr. D',
            canPerformCaesars: false,
            canPerformAnaesthetics: false),
        Doctor(
            name: 'Dr. E',
            canPerformCaesars: true,
            canPerformAnaesthetics: true),
        Doctor(
            name: 'Dr. F',
            canPerformCaesars: false,
            canPerformAnaesthetics: false),
      ];
      final shifts = [
        Shift(date: DateTime(2024, 6, 1), type: 'Weekday'),
        Shift(date: DateTime(2024, 6, 2), type: 'Weekday'),
      ];
      final hoursPerShiftType = {
        'Overnight Weekday': 16.0,
        'Second On Call Weekday': 6.0,
        'Caesar Cover Weekday': 3.0,
        'Overnight Weekend': 12.0,
        'Day Weekend': 12.0,
        'Caesar Cover Weekend': 3.6,
      };

      final roster = Roster(
        doctors: doctors,
        shifts: shifts,
        hoursPerShiftType: hoursPerShiftType,
      );

      roster.assignShifts();

      expect(shifts[0].mainDoctor, isNotNull);
      expect(shifts[1].mainDoctor, isNotNull);
    });

    // Add more tests as needed
  });
}
