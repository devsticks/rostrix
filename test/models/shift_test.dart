import 'package:flutter_test/flutter_test.dart';
import 'package:rostrem/models/shift.dart';
import 'package:rostrem/models/doctor.dart';

void main() {
  group('Shift Model Tests', () {
    test('Shift can be instantiated', () {
      final date = DateTime(2024, 6, 1);
      final shift = Shift(date: date, type: 'Weekday');
      expect(shift.date, date);
      expect(shift.type, 'Weekday');
    });

    // Add more tests as needed
  });
}
