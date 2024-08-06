import 'package:flutter_test/flutter_test.dart';
import 'package:rostrem/models/assignment_generator.dart';
import 'package:rostrem/models/roster.dart';
import 'package:rostrem/models/shift.dart';
import 'package:rostrem/models/doctor.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'roster_test.mocks.dart';

// class MockBuildContext extends Mock implements BuildContext {}

@GenerateNiceMocks([
  MockSpec<BuildContext>(),
  MockSpec<FileSaveLocation>(),
  MockSpec<XTypeGroup>(),
  MockSpec<AssignmentGenerator>()
])
void main() {
  group('Roster model tests', () {
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
      weekdayShiftHours = hoursPerShiftType['Overnight Weekday']! +
          hoursPerShiftType['Caesar Cover Weekday']! +
          hoursPerShiftType['Second On Call Weekday']!;
      weekendShiftHours = 2 * hoursPerShiftType['Day Weekend']! +
          hoursPerShiftType['Caesar Cover Weekend']! +
          hoursPerShiftType['Overnight Weekend']!;
      assigner = AssignmentGenerator(hoursPerShiftType: hoursPerShiftType);
      roster = Roster(
        doctors: doctors,
        shifts: shifts,
        assigner: assigner,
      );
    });

    test('Roster can be instantiated', () {
      expect(roster, isNotNull, reason: 'Roster should not be null');
    });

    test('Roster doctors are initialized correctly', () {
      expect(roster.doctors, doctors,
          reason: 'Roster doctors should be initialized correctly');
    });

    test('Roster shifts are initialized correctly', () {
      expect(roster.shifts, shifts,
          reason: 'Roster shifts should be initialized correctly');
    });

    test('Roster assigner is initialized correctly', () {
      expect(roster.assigner, assigner,
          reason: 'Roster assigner should be initialized correctly');
    });

    test('Roster is not filled initially', () {
      expect(roster.filled, isFalse, reason: 'Roster should not be filled');
    });

    test('retryAssignments() calls assigner.retryAssignments()', () async {
      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
      AssignmentGenerator assigner = MockAssignmentGenerator();
      Roster roster = Roster(
        doctors: doctors,
        shifts: shifts,
        assigner: assigner,
      );
      await roster.retryAssignments(3, progressNotifier);

      verify(assigner.retryAssignments(roster, 3, progressNotifier));
    });

    test('Roster can be deeply copied', () {
      Roster copy = roster.copy();

      expect(copy, isNot(same(roster)),
          reason: 'Copied roster should not be the same as the original');
      expect(copy.doctors, roster.doctors,
          reason: 'Copied roster doctors should be the same as the original');
      expect(copy.shifts, roster.shifts,
          reason: 'Copied roster shifts should be the same as the original');
      expect(copy.assigner, roster.assigner,
          reason: 'Copied roster assigner should be the same as the original');
    });

    test('Roster can be cleared', () {
      roster.clearAssignments();

      for (var shift in roster.shifts) {
        expect(shift.mainDoctor, isNull,
            reason: 'Main doctor should be null after clearing');
        expect(shift.caesarCoverDoctor, isNull,
            reason: 'Caesar cover doctor should be null after clearing');
        expect(shift.secondOnCallDoctor, isNull,
            reason: 'Second on call doctor should be null after clearing');
        expect(shift.weekendDayDoctor, isNull,
            reason: 'Weekend day doctor should be null after clearing');
      }
      expect(roster.filled, isFalse, reason: 'Roster should not be filled');
    });

    test('Roster can be compared', () {
      Roster secondRoster = Roster(
        doctors: doctors,
        shifts: shifts,
        assigner: assigner,
      );

      expect(secondRoster == roster, isTrue,
          reason: 'Copied roster should be equal to the original');
    });

    test('Roster copy can be compared', () {
      Roster copy = roster.copy();

      expect(copy == roster, isTrue,
          reason: 'Copied roster should be equal to the original');
    });

    test('getAvailableDoctors() returns doctors available for a shift', () {
      List<Doctor>? availableDoctors = roster.getAvailableDoctors(
        'Overnight Weekday',
        DateTime.now(),
      );

      expect(availableDoctors, isNotEmpty,
          reason: 'Available doctors should not be empty');
    });

    test('retryAssignments() updates the passed progressNotifier', () async {
      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

      await roster.retryAssignments(3, progressNotifier);

      expect(progressNotifier.value, 1.0,
          reason: 'Progress notifier should be at 1.0 after retries');
    });

    test(
        'retryAssignments() updates the overtime correctly for the relevant doctors for a single weekday shift roster',
        () async {
      roster.shifts = [shifts[0]];

      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
      await roster.retryAssignments(100, progressNotifier);

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
        'retryAssignments() updates the overtime correctly for the relevant doctors for a single weekend shift roster',
        () async {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 4, 6), type: 'Weekend'),
      ]; // a Sunday

      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
      await roster.retryAssignments(100, progressNotifier);

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
        'retryAssignments() updates the overtime correctly for the relevant doctors for a weekday & weekend shift roster',
        () async {
      roster.shifts = [
        Shift(date: DateTime(2024, 8, 4, 6), type: 'Weekend'),
        Shift(date: DateTime(2024, 8, 7, 6), type: 'Weekday')
      ]; // a Sunday and Wednesday

      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);
      await roster.retryAssignments(100, progressNotifier);

      expect(roster.filled, isTrue, reason: 'Roster should be filled');

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
