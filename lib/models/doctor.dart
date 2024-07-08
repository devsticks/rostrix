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

  /// Given a list of days, produces a list additionally containing any contiguous
  /// weekends and public holidays, as well as the preceding Friday.
  List<DateTime> getExpandedLeaveDays() {
    Set<DateTime> expandedDays = Set<DateTime>.from(leaveDays);

    for (DateTime day in leaveDays) {
      // Add the day itself
      expandedDays.add(day);

      // Check and add preceding days (including Friday)
      DateTime current = day.subtract(Duration(days: 1));
      while (current.weekday == DateTime.sunday ||
          current.weekday == DateTime.saturday ||
          isPublicHoliday(current) ||
          current.weekday == DateTime.friday) {
        expandedDays.add(current);
        current = current.subtract(Duration(days: 1));
      }

      // Check and add following days
      current = day.add(Duration(days: 1));
      while (current.weekday == DateTime.saturday ||
          current.weekday == DateTime.sunday ||
          isPublicHoliday(current)) {
        expandedDays.add(current);
        current = current.add(Duration(days: 1));
      }
    }

    return expandedDays.toList()..sort();
  }

  bool isPublicHoliday(DateTime date) {
    int year = date.year;
    List<DateTime> publicHolidays = getPublicHolidays(year);
    return publicHolidays.contains(date);
  }

  // Helper function to check if a given date is a public holiday
  List<DateTime> getPublicHolidays(int year) {
    List<DateTime> publicHolidays = [
      DateTime(year, 1, 1), // New Year's Day
      DateTime(year, 3, 21), // Human Rights Day
      DateTime(year, 4, 27), // Freedom Day
      DateTime(year, 5, 1), // Workers' Day
      DateTime(year, 6, 16), // Youth Day
      DateTime(year, 8, 9), // National Women's Day
      DateTime(year, 9, 24), // Heritage Day
      DateTime(year, 12, 16), // Day of Reconciliation
      DateTime(year, 12, 25), // Christmas Day
      DateTime(year, 12, 26), // Day of Goodwill
    ];

    // Adjust holidays falling on a Sunday
    publicHolidays = publicHolidays.map((holiday) {
      if (holiday.weekday == DateTime.sunday) {
        return holiday.add(const Duration(days: 1));
      }
      return holiday;
    }).toList();

    return publicHolidays;
  }
}
