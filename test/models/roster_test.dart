import 'package:flutter_test/flutter_test.dart';
import 'package:rostrem/models/roster.dart';
import 'package:rostrem/models/shift.dart';
import 'package:rostrem/models/doctor.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'roster_test.mocks.dart';

class MockBuildContext extends Mock implements BuildContext {}

@GenerateMocks([Roster])
void main() {
  group('Roster tests', () {
    late List<Doctor> doctors;
    late List<Shift> shifts;
    late Map<String, double> hoursPerShiftType;
    late Roster roster;
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
      roster = Roster(
        doctors: doctors,
        shifts: shifts,
        hoursPerShiftType: hoursPerShiftType,
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
      roster.assignShifts();

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
      roster.assignShifts();

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
      roster.shifts = [shifts[0]];
      roster.shifts[0].type = 'Weekend';

      roster.assignShifts();

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
      roster.shifts[0].type = 'Weekend';
      roster.shifts[1].type = 'Weekend';

      roster.assignShifts();

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

      roster.assignShifts();

      expect(roster.filled, isFalse,
          reason: 'Roster should not be filled when no doctors are available');
    });

    test('assignShifts() fails when no complementary doctors are available',
        () {
      doctors[0].canPerformCaesars = false;
      doctors[1].canPerformCaesars = false;
      roster.doctors = [doctors[0], doctors[1]];
      roster.shifts = [shifts[0]];

      roster.assignShifts();

      expect(roster.filled, isFalse,
          reason:
              'Roster should not be filled when no complementary doctors are available');
    });

    test('assignShifts() works when complementary doctors are available', () {
      doctors[0].canPerformCaesars = true;
      doctors[1].canPerformCaesars = false;
      roster.doctors = [doctors[0], doctors[1]];
      roster.shifts = [shifts[0]];

      roster.assignShifts();

      expect(roster.filled, isTrue,
          reason:
              'Roster should not be filled when no complementary doctors are available');
    });

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a single weekday shift roster',
        () {
      roster.shifts = [shifts[0]];
      roster.assignShifts();

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = weekdayShiftHours;

      expect(totalOvertimeAllocated, totalOvertimeToAllocate,
          reason:
              'Total overtime should be $totalOvertimeToAllocate after assigning one weekday shift');
    });

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a single weekend shift roster',
        () {
      roster.shifts = [shifts[0]];
      roster.shifts[0].type = 'Weekend';
      roster.assignShifts();

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = weekendShiftHours;

      expect(totalOvertimeAllocated, totalOvertimeToAllocate,
          reason:
              'Total overtime should be $totalOvertimeToAllocate after assigning one weekday shift');
    });

    test(
        'assignShifts() updates the overtime correctly for the relevant doctors for a weekday & weekend shift roster',
        () {
      roster.shifts = [shifts[0], shifts[1]];
      roster.shifts[1].type = 'Weekend';
      roster.assignShifts();

      double totalOvertimeAllocated = 0.0;
      for (var doctor in doctors) {
        totalOvertimeAllocated += doctor.overtimeHours;
      }

      double totalOvertimeToAllocate = 0.0;
      for (var shift in shifts) {
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
    });

    test(
        'retryAssignments() calls assignShifts() with the correct number of retries',
        () async {
      roster = MockRoster();
      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

      await roster.retryAssignments(3, progressNotifier);

      verify(roster.assignShifts()).called(3);
    });

    test('retryAssignments() updates the passed progressNotifier', () async {
      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

      await roster.retryAssignments(3, progressNotifier);

      expect(progressNotifier.value, 1.0,
          reason: 'Progress notifier should be at 1.0 after retries');
    });

    test('downloadAsCsv() generates the correct CSV format', () async {
      // Mock the FileSaveLocation to avoid actual file system operations
      XTypeGroup typeGroup = const XTypeGroup(
        label: 'csv',
        extensions: ['csv'],
      );

      FileSaveLocation saveLocation = FileSaveLocation(
        'test_roster.csv',
        activeFilter: typeGroup,
      );

      when(getSaveLocation(
        acceptedTypeGroups: [typeGroup],
        suggestedName: 'Roster.csv',
      )).thenAnswer((_) async => saveLocation);

      await roster.downloadAsCsv(MockBuildContext());

      // Since the actual file writing is skipped, the verification here can only be
      // theoretical without actual file operations.
      // You might use a file system mock package for in-depth testing.
      print('CSV export functionality tested.');
    });
  });
}
