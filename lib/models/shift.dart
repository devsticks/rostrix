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
  }) {
    if (type == 'Weekday' && type != 'Holiday' && weekendDayDoctor != null) {
      throw ArgumentError(
          'Weekday (non-holiday) shifts cannot have weekend day doctors. Expected `weekendDayDoctor` to be null, but got $weekendDayDoctor.');
    }
  }

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

  @override
  String toString() {
    return 'Shift(date: $date, type: $type, mainDoctor: $mainDoctor, caesarCoverDoctor: $caesarCoverDoctor, secondOnCallDoctor: $secondOnCallDoctor, weekendDayDoctor: $weekendDayDoctor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Shift &&
        other.date == date &&
        other.type == type &&
        other.mainDoctor == mainDoctor &&
        other.caesarCoverDoctor == caesarCoverDoctor &&
        other.secondOnCallDoctor == secondOnCallDoctor &&
        other.weekendDayDoctor == weekendDayDoctor;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        type.hashCode ^
        mainDoctor.hashCode ^
        caesarCoverDoctor.hashCode ^
        secondOnCallDoctor.hashCode ^
        weekendDayDoctor.hashCode;
  }
}
