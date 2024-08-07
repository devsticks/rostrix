import 'package:flutter_test/flutter_test.dart';
import 'package:rostrix/models/assignment_generator.dart';
import 'package:rostrix/models/roster.dart';
import 'package:rostrix/models/shift.dart';
import 'package:rostrix/models/doctor.dart';

void main() {
  group('AssignmentGenerator model tests', () {
    late List<Doctor> doctors;
    late List<Shift> shifts;
    late Map<String, double> hoursPerShiftType;
    late Roster roster;
    late AssignmentGenerator assigner;

    setUp(() {
      doctors = [
        Doctor(
            name: 'Dr. A',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. B',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. C',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. D',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
      ];
      shifts = [
        Shift(
            date: DateTime(2024, 8, 6, 6), // a Tuesday
            type: 'Weekday'),
        Shift(date: DateTime(2024, 8, 7, 6), type: 'Weekday'),
      ];
      hoursPerShiftType = {
        'Overnight Weekday': 12,
        'Caesar Cover Weekday': 8,
        'Second On Call Weekday': 6,
        'Day Weekend': 10,
        'Caesar Cover Weekend': 10,
        'Overnight Weekend': 14,
      };
      assigner = AssignmentGenerator(hoursPerShiftType: hoursPerShiftType);
      roster = Roster(
        doctors: doctors,
        shifts: shifts,
        assigner: assigner,
      );
    });

    test('AssignmentGenerator can be instantiated', () {
      expect(assigner, isNotNull,
          reason: 'AssignmentGenerator should not be null');
    });

    test('AssignmentGenerator can be instantiated with hoursPerShiftType', () {
      expect(assigner.hoursPerShiftType, equals(hoursPerShiftType));
    });

    test('AssignmentGenerator can be compared', () {
      final assigner2 =
          AssignmentGenerator(hoursPerShiftType: hoursPerShiftType);
      expect(assigner, equals(assigner2));
    });

    test('AssignmentGenerator can be copied', () {
      final copy = assigner.copy();
      expect(copy, equals(assigner));
    });

    test('Copied AssignmentGenerator has different reference', () {
      final copy = assigner.copy();
      expect(identical(copy, assigner), isFalse);
    });

    test('Copied AssignmentGenerator can be compared', () {
      final copy = assigner.copy();
      expect(copy == assigner, isTrue);
    });
  });

  group('Roster assignment tests', () {
    late List<Doctor> doctors;
    late List<Shift> shifts;
    late Map<String, double> hoursPerShiftType;
    late Roster roster;
    late AssignmentGenerator assigner;
    late double weekdayShiftHours;
    late double weekendShiftHours;

    setUp(() {
      doctors = [
        Doctor(
            name: 'Dr. A',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. B',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. C',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
        Doctor(
            name: 'Dr. D',
            canPerformAnaesthetics: true,
            canPerformCaesars: true),
      ];
      shifts = [
        Shift(
            date: DateTime.now().subtract(const Duration(days: 1)),
            type: 'Weekday'),
        Shift(date: DateTime.now(), type: 'Weekday'),
      ];
      hoursPerShiftType = {
        'Overnight Weekday': 12,
        'Caesar Cover Weekday': 8,
        'Second On Call Weekday': 6,
        'Day Weekend': 10,
        'Caesar Cover Weekend': 10,
        'Overnight Weekend': 14,
      };
      assigner = AssignmentGenerator(hoursPerShiftType: hoursPerShiftType);
      roster = Roster(
        doctors: doctors,
        shifts: shifts,
        assigner: assigner,
      );
      weekdayShiftHours = hoursPerShiftType['Overnight Weekday']! +
          hoursPerShiftType['Caesar Cover Weekday']! +
          hoursPerShiftType['Second On Call Weekday']!;
      weekendShiftHours = 2 * hoursPerShiftType['Day Weekend']! +
          hoursPerShiftType['Caesar Cover Weekend']! +
          hoursPerShiftType['Overnight Weekend']!;
    });

    test('assignShifts() assigns all shifts for single-shift weekday roster',
        () {
      roster.shifts = [shifts[0]];
      assigner.assignShifts(roster);

      for (var shift in roster.shifts) {
        expect(shift.mainDoctor, isNotNull,
            reason: 'Main doctor is not assigned for shift on ${shift.date}');
        expect(shift.caesarCoverDoctor, isNotNull,
            reason:
                'Caesar cover doctor is not assigned for shift on ${shift.date}');
        expect(shift.secondOnCallDoctor, isNotNull,
            reason:
                'Second on call doctor is not assigned for shift on ${shift.date}');
      }
      expect(roster.filled, isTrue, reason: 'Roster is not fully filled');
    });

    test('assignShifts() assigns all shifts for two-shift weekday roster', () {
      roster.shifts = shifts;
      bool result = assigner.assignShifts(roster);

      for (var shift in roster.shifts) {
        expect(shift.mainDoctor, isNotNull,
            reason: 'Main doctor is not assigned for shift on ${shift.date}');
        expect(shift.caesarCoverDoctor, isNotNull,
            reason:
                'Caesar cover doctor is not assigned for shift on ${shift.date}');
        expect(shift.secondOnCallDoctor, isNotNull,
            reason:
                'Second on call doctor is not assigned for shift on ${shift.date}');
      }
      expect(roster.filled, isTrue, reason: 'Roster is not fully filled');
    });

    test('assignShifts() assigns all shifts for single-shift weekend roster',
        () {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 3, 6), type: 'Weekend')
      ]; // a Saturday

      assigner.assignShifts(roster);

      for (var shift in roster.shifts) {
        expect(shift.mainDoctor, isNotNull,
            reason: 'Main doctor is not assigned for shift on ${shift.date}');
        expect(shift.caesarCoverDoctor, isNotNull,
            reason:
                'Caesar cover doctor is not assigned for shift on ${shift.date}');
        expect(shift.secondOnCallDoctor, isNotNull,
            reason:
                'Second on call doctor is not assigned for shift on ${shift.date}');
      }
      expect(roster.filled, isTrue, reason: 'Roster is not fully filled');
    });

    test('assignShifts() assigns all shifts for two-shift weekend roster', () {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 3, 6), type: 'Weekend'),
        Shift(date: DateTime(2024, 8, 4, 6), type: 'Weekend')
      ]; // a Saturday and a Sunday

      assigner.assignShifts(roster);

      for (var shift in roster.shifts) {
        expect(shift.mainDoctor, isNotNull,
            reason: 'Main doctor is not assigned for shift on ${shift.date}');
        expect(shift.caesarCoverDoctor, isNotNull,
            reason:
                'Caesar cover doctor is not assigned for shift on ${shift.date}');
        expect(shift.secondOnCallDoctor, isNotNull,
            reason:
                'Second on call doctor is not assigned for shift on ${shift.date}');
      }
      expect(roster.filled, isTrue, reason: 'Roster is not fully filled');
    });

    test('assignShifts() fails when no doctors are available', () {
      roster.doctors = [];
      assigner.assignShifts(roster);

      expect(roster.filled, isFalse,
          reason: 'Roster should not be filled when no doctors are available');
    });

    test('assignShifts() fails when no complementary doctors are available',
        () {
      doctors[0].canPerformCaesars = false;
      doctors[1].canPerformCaesars = false;
      roster.doctors = [doctors[0], doctors[1]];
      roster.shifts = [shifts[0]];

      assigner.assignShifts(roster);

      expect(roster.filled, isFalse,
          reason:
              'Roster should not be filled when no complementary doctors are available');
    });

    test('assignShifts() works when complementary doctors are available', () {
      doctors[0].canPerformCaesars = true;
      doctors[1].canPerformCaesars = false;
      roster.doctors = [doctors[0], doctors[1]];
      roster.shifts = [shifts[0]];

      assigner.assignShifts(roster);

      expect(roster.filled, isTrue,
          reason:
              'Roster should not be filled when no complementary doctors are available');
    });

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a single weekday shift roster',
        () {
      roster.shifts = [shifts[0]];
      assigner.assignShifts(roster);

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = weekdayShiftHours;

      expect(totalOvertimeAllocated, totalOvertimeToAllocate,
          reason:
              'Total overtime should be $totalOvertimeToAllocate after assigning one weekday shift');
    }, retry: 100);

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a single weekend shift roster',
        () {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 3, 6), type: 'Weekend')
      ]; // a Saturday
      assigner.assignShifts(roster);

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = weekendShiftHours;

      expect(totalOvertimeAllocated, totalOvertimeToAllocate,
          reason:
              'Total overtime should be $totalOvertimeToAllocate after assigning one weekday shift');
    }, retry: 100);

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a weekday & weekend shift roster',
        () {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 4, 6), type: 'Weekend'),
        Shift(date: DateTime(2024, 8, 7, 6), type: 'Weekday')
      ]; // a Sunday and Wednesday
      assigner.assignShifts(roster);

      expect(roster.filled, isTrue, reason: 'Roster is not fully filled');

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = 0.0;
      for (var shift in roster.shifts) {
        if (shift.type == 'Weekday') {
          totalOvertimeToAllocate += weekdayShiftHours;
        }
        if (shift.type == 'Weekend') {
          totalOvertimeToAllocate += weekendShiftHours;
        }
      }

      expect(totalOvertimeAllocated, totalOvertimeToAllocate,
          reason:
              'Total overtime should be $totalOvertimeToAllocate after assigning one weekday and one weekend shift');
    }, retry: 100);
  });
}
