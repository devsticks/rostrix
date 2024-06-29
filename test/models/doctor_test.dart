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

    // Add more tests as needed
  });
}
