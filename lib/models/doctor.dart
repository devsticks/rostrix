class Doctor {
  String name;
  bool canPerformCaesars;
  bool canPerformAnaesthetics;
  double overtimeHours;
  int overnightWeekdayCalls;
  int secondOnCallWeekdayCalls;
  int caesarCoverWeekdayCalls;
  int weekendCalls;
  int caesarCoverWeekendCalls;
  List<DateTime> leaveDays;

  Doctor({
    required this.name,
    required this.canPerformCaesars,
    required this.canPerformAnaesthetics,
    this.overtimeHours = 0,
    this.overnightWeekdayCalls = 0,
    this.secondOnCallWeekdayCalls = 0,
    this.caesarCoverWeekdayCalls = 0,
    this.weekendCalls = 0,
    this.caesarCoverWeekendCalls = 0,
    List<DateTime>? leaveDays,
  }) : leaveDays = leaveDays ?? [];

  Doctor copy() {
    return Doctor(
      name: name,
      canPerformCaesars: canPerformCaesars,
      canPerformAnaesthetics: canPerformAnaesthetics,
      overtimeHours: overtimeHours,
      overnightWeekdayCalls: overnightWeekdayCalls,
      secondOnCallWeekdayCalls: secondOnCallWeekdayCalls,
      caesarCoverWeekdayCalls: caesarCoverWeekdayCalls,
      weekendCalls: weekendCalls,
      caesarCoverWeekendCalls: caesarCoverWeekendCalls,
      leaveDays: List.from(leaveDays),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          canPerformCaesars == other.canPerformCaesars &&
          canPerformAnaesthetics == other.canPerformAnaesthetics &&
          overtimeHours == other.overtimeHours &&
          overnightWeekdayCalls == other.overnightWeekdayCalls &&
          secondOnCallWeekdayCalls == other.secondOnCallWeekdayCalls &&
          caesarCoverWeekdayCalls == other.caesarCoverWeekdayCalls &&
          weekendCalls == other.weekendCalls &&
          caesarCoverWeekendCalls == other.caesarCoverWeekendCalls &&
          _listEquals(leaveDays, other.leaveDays);

  @override
  int get hashCode =>
      name.hashCode ^
      canPerformCaesars.hashCode ^
      canPerformAnaesthetics.hashCode ^
      overtimeHours.hashCode ^
      overnightWeekdayCalls.hashCode ^
      secondOnCallWeekdayCalls.hashCode ^
      caesarCoverWeekdayCalls.hashCode ^
      weekendCalls.hashCode ^
      caesarCoverWeekendCalls.hashCode ^
      leaveDays.hashCode;

  bool _listEquals(List<DateTime> list1, List<DateTime> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
