import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rostrem/models/doctor.dart';

void main() {
  group('Doctor Model Tests', () {
    test('Doctor can be instantiated', () {
      final doctor = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      expect(doctor.name, 'Dr. Test');
      expect(doctor.canPerformCaesars, true);
      expect(doctor.canPerformAnaesthetics, false);
    });

    test('Hours can be added to a doctor', () {
      final doctor = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor.overtimeHours = 10;
      expect(doctor.overtimeHours, 10);
    });

    test('Shifts can be added to a doctor', () {
      final doctor = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor.overnightWeekdayCalls = 1;
      doctor.secondOnCallWeekdayCalls = 2;
      doctor.caesarCoverWeekdayCalls = 3;
      doctor.weekendCalls = 4;
      doctor.caesarCoverWeekendCalls = 5;
      expect(doctor.overnightWeekdayCalls, 1);
      expect(doctor.secondOnCallWeekdayCalls, 2);
      expect(doctor.caesarCoverWeekdayCalls, 3);
      expect(doctor.weekendCalls, 4);
      expect(doctor.caesarCoverWeekendCalls, 5);
    });

    test('Leave days can be added to a doctor', () {
      Doctor doctor = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor.leaveDays.add(DateTime.now());
      expect(doctor.leaveDays.length, 1);
    });

    test('Doctor can be copied', () {
      final doctor = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final copy = doctor.copy();
      expect(copy.name, doctor.name);
      expect(copy.canPerformCaesars, doctor.canPerformCaesars);
      expect(copy.canPerformAnaesthetics, doctor.canPerformAnaesthetics);
      expect(copy.overtimeHours, doctor.overtimeHours);
      expect(copy.overnightWeekdayCalls, doctor.overnightWeekdayCalls);
      expect(copy.secondOnCallWeekdayCalls, doctor.secondOnCallWeekdayCalls);
      expect(copy.caesarCoverWeekdayCalls, doctor.caesarCoverWeekdayCalls);
      expect(copy.weekendCalls, doctor.weekendCalls);
      expect(copy.caesarCoverWeekendCalls, doctor.caesarCoverWeekendCalls);
      expect(copy.leaveDays, doctor.leaveDays);
    });

    test('Doctor can be compared', () {
      final today = DateTime.now();
      Doctor doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor1.overtimeHours = 10;
      doctor1.overnightWeekdayCalls = 1;
      doctor1.secondOnCallWeekdayCalls = 2;
      doctor1.caesarCoverWeekdayCalls = 3;
      doctor1.weekendCalls = 4;
      doctor1.caesarCoverWeekendCalls = 5;
      doctor1.leaveDays.add(today);
      Doctor doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.overtimeHours = 10;
      doctor2.overnightWeekdayCalls = 1;
      doctor2.secondOnCallWeekdayCalls = 2;
      doctor2.caesarCoverWeekdayCalls = 3;
      doctor2.weekendCalls = 4;
      doctor2.caesarCoverWeekendCalls = 5;
      doctor2.leaveDays.add(today);
      expect(doctor1 == doctor2, true);
    });

    test('Copied Doctor can be compared', () {
      final today = DateTime.now();
      Doctor doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor1.overtimeHours = 10;
      doctor1.overnightWeekdayCalls = 1;
      doctor1.secondOnCallWeekdayCalls = 2;
      doctor1.caesarCoverWeekdayCalls = 3;
      doctor1.weekendCalls = 4;
      doctor1.caesarCoverWeekendCalls = 5;
      doctor1.leaveDays.add(today);
      Doctor doctor2 = doctor1.copy();
      expect(doctor1 == doctor2, true);
    });

    test('Doctor can be compared for identical objects', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      Doctor doctor2 = doctor1;
      expect(identical(doctor1, doctor2), true);
    });

    test('Doctor can be compared with different skill values', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different overtime hours values', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.overtimeHours = 10;
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different weekday overnight values', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.overnightWeekdayCalls = 1;
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different weekday 2nd-on-call values',
        () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.secondOnCallWeekdayCalls = 2;
      expect(doctor1 == doctor2, false);
    });

    test(
        'Doctor can be compared with different weekday caesar cover call values',
        () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.caesarCoverWeekdayCalls = 3;
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different weekend call values', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.weekendCalls = 4;
      expect(doctor1 == doctor2, false);
    });

    test(
        'Doctor can be compared with different weekend caesar cover call values',
        () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.caesarCoverWeekendCalls = 5;
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different leave days values', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      doctor2.leaveDays.add(DateTime.now());
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with different names', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor2 = Doctor(
          name: 'Dr. Test 2',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      expect(doctor1 == doctor2, false);
    });

    test('Doctor can be compared with null', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      expect(doctor1 == null, false);
    });

    test('Doctor can be compared with itself', () {
      final doctor1 = Doctor(
          name: 'Dr. Test',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      expect(doctor1 == doctor1, true);
    });
  });

  group('Doctor leave expansion tests', () {
    // Define the Doctor object outside the individual tests
    late Doctor doctor;

    // Use setUp to initialize the Doctor object before each test
    setUp(() {
      doctor = Doctor(
        name: 'Dr Test',
        canPerformCaesars: true,
        canPerformAnaesthetics: true,
      );
    });

    test('Leave expansion includes weekend before a Monday', () {
      doctor.leaveDays.add(DateTime(2024, 7, 8));
      expect(doctor.leaveDays[0].weekday, DateTime.monday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 7)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 6)), true);
    });

    test('Leave expansion includes Friday before a Monday', () {
      doctor.leaveDays.add(DateTime(2024, 7, 8));
      expect(doctor.leaveDays[0].weekday, DateTime.monday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 5)), true);
    });

    test(
        'Leave expansion includes weekend and Friday before a Monday, but excludes all other days (in month)',
        () {
      doctor.leaveDays.add(DateTime(2024, 7, 8));
      expect(doctor.leaveDays[0].weekday, DateTime.monday);
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 5)), true,
          reason:
              'Friday ${DateTime(2024, 7, 5)} should be included in expansion of Monday ${DateTime(2024, 7, 8)}');
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 6)), true,
          reason:
              'Saturday ${DateTime(2024, 7, 6)} should be included in expansion of Monday ${DateTime(2024, 7, 8)}');
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 7)), true,
          reason:
              'Sunday ${DateTime(2024, 7, 7)} should be included in expansion of Monday ${DateTime(2024, 7, 8)}');
      for (int i = 1; i < 5; i++) {
        expect(
            doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, i)), false,
            reason:
                'Day ${DateTime(2024, 7, i)} should not be included in expansion of Monday ${DateTime(2024, 7, 8)}');
      }
      for (int i = 9; i < 31; i++) {
        expect(
            doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, i)), false,
            reason:
                'Day ${DateTime(2024, 7, i)} should not be included in expansion of Monday ${DateTime(2024, 7, 8)}');
      }
    });

    test('Leave expansion includes weekend after a Friday', () {
      doctor.leaveDays.add(DateTime(2024, 7, 5));
      expect(doctor.leaveDays[0].weekday, DateTime.friday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 6)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 7)), true);
    });

    test('Leave expansion includes preceding weekday', () {
      doctor.leaveDays.add(DateTime(2024, 7, 5));
      expect(doctor.leaveDays[0].weekday, DateTime.friday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 4)), true);
    });

    test(
        'Leave expansion includes weekend after and Thursday before a Friday, but excludes all other days (in month)',
        () {
      doctor.leaveDays.add(DateTime(2024, 7, 5));
      expect(doctor.leaveDays[0].weekday, DateTime.friday);
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 4)), true,
          reason:
              'Thursday ${DateTime(2024, 7, 4)} should be included in expansion of Friday ${DateTime(2024, 7, 5)}');
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 6)), true,
          reason:
              'Saturday ${DateTime(2024, 7, 6)} should be included in expansion of Friday ${DateTime(2024, 7, 5)}');
      expect(doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, 7)), true,
          reason:
              'Sunday ${DateTime(2024, 7, 7)} should be included in expansion of Friday ${DateTime(2024, 7, 5)}');
      for (int i = 1; i < 4; i++) {
        expect(
            doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, i)), false,
            reason:
                '${DateTime(2024, 7, i)} (${DateFormat('EEEE').format(DateTime(2024, 7, i))}) should not be included in expansion of Friday ${DateTime(2024, 7, 5)}');
      }
      for (int i = 9; i < 31; i++) {
        expect(
            doctor.getExpandedLeaveDays().contains(DateTime(2024, 7, i)), false,
            reason:
                '${DateTime(2024, 7, i)} (${DateFormat('EEEE').format(DateTime(2024, 7, i))}) should not be included in expansion of Friday ${DateTime(2024, 7, 5)}');
      }
    });

    test(
        'Leave expansion includes all contiguous public holidays after a Friday',
        () {
      doctor.leaveDays.add(DateTime(2023, 12, 22));
      expect(doctor.leaveDays[0].weekday, DateTime.friday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 12, 25)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 12, 26)), true);
    });

    test(
        'Leave expansions includes contiguous public holidays following a weekday',
        () {
      doctor.leaveDays.add(DateTime(2023, 06, 15));
      expect(doctor.leaveDays[0].weekday, DateTime.thursday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 6, 16)), true);
    });

    test(
        'Leave expansions includes contiguous public holidays following a weekday and the weekend if public holiday is a Friday',
        () {
      doctor.leaveDays.add(DateTime(2023, 06, 15));
      expect(doctor.leaveDays[0].weekday, DateTime.thursday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 6, 16)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 6, 17)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 6, 18)), true);
    });

    test(
        'Leave expansion includes contiguous public holidays preceding a weekday',
        () {
      doctor.leaveDays.add(DateTime(2023, 5, 2));
      expect(doctor.leaveDays[0].weekday, DateTime.tuesday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 5, 1)), true);
    });

    test(
        'Leave expansion includes contiguous public holidays preceding a weekday plus the weekend and Friday if public holiday is a Monday',
        () {
      doctor.leaveDays.add(DateTime(2023, 5, 2));
      expect(doctor.leaveDays[0].weekday, DateTime.tuesday);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 5, 1)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 4, 30)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 4, 29)), true);
      expect(
          doctor.getExpandedLeaveDays().contains(DateTime(2023, 4, 28)), true);
    });
  });
}
