import 'doctor.dart';

class Shift {
  DateTime date;
  String type; // e.g., 'Weekday', 'Weekend', 'Holiday'
  Doctor? mainDoctor;
  Doctor? caesarCoverDoctor;
  Doctor? secondOnCallDoctor;
  Doctor? weekendDayDoctor;

  Shift({
    required this.date,
    required this.type,
    this.mainDoctor,
    this.caesarCoverDoctor,
    this.secondOnCallDoctor,
    this.weekendDayDoctor,
  });

  Shift copy() {
    return Shift(
      date: date,
      type: type,
      mainDoctor: mainDoctor?.copy(),
      caesarCoverDoctor: caesarCoverDoctor?.copy(),
      secondOnCallDoctor: secondOnCallDoctor?.copy(),
      weekendDayDoctor: weekendDayDoctor?.copy(),
    );
  }
}
