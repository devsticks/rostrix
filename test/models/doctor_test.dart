import 'package:flutter_test/flutter_test.dart';
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
}
