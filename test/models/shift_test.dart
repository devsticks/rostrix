import 'package:flutter_test/flutter_test.dart';
import 'package:rostrix/models/shift.dart';
import 'package:rostrix/models/doctor.dart';

void main() {
  group('Shift Model Tests', () {
    test('Shift can be instantiated', () {
      final date = DateTime(2024, 6, 1);
      final shift = Shift(date: date, type: 'Weekday');
      expect(shift.date, date);
      expect(shift.type, 'Weekday');
    });

    test('Weekday shift can be instantiated with doctors', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Weekday',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3);
      expect(shift.date, date);
      expect(shift.type, 'Weekday');
      expect(shift.mainDoctor, doctor1);
      expect(shift.caesarCoverDoctor, doctor2);
      expect(shift.secondOnCallDoctor, doctor3);
    });

    test('Weekend shift can be instantiated with doctors', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          weekendDayDoctor: doctor2,
          caesarCoverDoctor: doctor3,
          secondOnCallDoctor: doctor4);
      expect(shift.date, date);
      expect(shift.type, 'Weekend');
      expect(shift.mainDoctor, doctor1);
      expect(shift.weekendDayDoctor, doctor2);
      expect(shift.caesarCoverDoctor, doctor3);
      expect(shift.secondOnCallDoctor, doctor4);
    });

    test('Holiday shift can be instantiated without doctors', () {
      final date = DateTime(2024, 6, 1);
      final shift = Shift(date: date, type: 'Holiday');
      expect(shift.date, date);
      expect(shift.type, 'Holiday');
    });

    test('Holiday shift can be instantiated with doctors', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Holiday',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      expect(shift.date, date);
      expect(shift.type, 'Holiday');
      expect(shift.mainDoctor, doctor1);
      expect(shift.caesarCoverDoctor, doctor2);
      expect(shift.secondOnCallDoctor, doctor3);
      expect(shift.weekendDayDoctor, doctor4);
    });

    test('Weekday shift can\'t be instantiated with weekendDayDoctor', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      expect(
          () => Shift(
              date: date,
              type: 'Weekday',
              mainDoctor: doctor1,
              weekendDayDoctor: doctor2,
              caesarCoverDoctor: doctor3,
              secondOnCallDoctor: doctor4),
          throwsArgumentError);
    });

    test('Weekday shift can be copied', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Weekday',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3);
      final copiedShift = shift.copy();
      expect(copiedShift.date, date);
      expect(copiedShift.type, 'Weekday');
      expect(copiedShift.mainDoctor, doctor1);
      expect(copiedShift.caesarCoverDoctor, doctor2);
      expect(copiedShift.secondOnCallDoctor, doctor3);
      expect(copiedShift.weekendDayDoctor, null);
    });

    test('Weekend shift can be copied', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          weekendDayDoctor: doctor2,
          caesarCoverDoctor: doctor3,
          secondOnCallDoctor: doctor4);
      final copiedShift = shift.copy();
      expect(copiedShift.date, date);
      expect(copiedShift.type, 'Weekend');
      expect(copiedShift.mainDoctor, doctor1);
      expect(copiedShift.weekendDayDoctor, doctor2);
      expect(copiedShift.caesarCoverDoctor, doctor3);
      expect(copiedShift.secondOnCallDoctor, doctor4);
    });

    test('Holiday shift can be copied', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift = Shift(
          date: date,
          type: 'Holiday',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final copiedShift = shift.copy();
      expect(copiedShift.date, date);
      expect(copiedShift.type, 'Holiday');
      expect(copiedShift.mainDoctor, doctor1);
      expect(copiedShift.caesarCoverDoctor, doctor2);
      expect(copiedShift.secondOnCallDoctor, doctor3);
      expect(copiedShift.weekendDayDoctor, doctor4);
    });

    test('Copied shift can be compared', () {
      final date = DateTime(2024, 6, 1);
      final shift = Shift(date: date, type: 'Weekday');
      final copiedShift = shift.copy();
      expect(shift == copiedShift, true);
    });

    test('Shift can be compared', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final shift2 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      expect(shift1 == shift2, true);
    });

    test('Shift can be compared for identical objects', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final shift2 = shift1;
      expect(identical(shift1, shift2), true);
    });

    test('Shift can be compared with different type values', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final shift2 = Shift(
          date: date,
          type: 'Weekday',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3);
      expect(shift1 == shift2, false);
    });

    test('Shift can be compared with different doctor values', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final shift2 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor3);
      expect(shift1 == shift2, false);
    });

    test('Shift can be compared with different date values', () {
      final date1 = DateTime(2024, 6, 1);
      final date2 = DateTime(2024, 6, 2);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date1,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      final shift2 = Shift(
          date: date2,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      expect(shift1 == shift2, false);
    });

    test('Shift can be compared with null', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      expect(shift1 == null, false);
    });

    test('Shift can be compared with itself', () {
      final date = DateTime(2024, 6, 1);
      final doctor1 = Doctor(
          name: 'Anderson',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor2 = Doctor(
          name: 'Bethe',
          canPerformCaesars: true,
          canPerformAnaesthetics: false);
      final doctor3 = Doctor(
          name: 'Carter',
          canPerformCaesars: true,
          canPerformAnaesthetics: true);
      final doctor4 = Doctor(
          name: 'Davies',
          canPerformCaesars: false,
          canPerformAnaesthetics: true);
      final shift1 = Shift(
          date: date,
          type: 'Weekend',
          mainDoctor: doctor1,
          caesarCoverDoctor: doctor2,
          secondOnCallDoctor: doctor3,
          weekendDayDoctor: doctor4);
      expect(shift1 == shift1, true);
    });
  });
}
