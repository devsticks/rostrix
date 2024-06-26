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
    this.leaveDays = const [],
  });

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
}
