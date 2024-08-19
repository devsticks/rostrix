import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'roster.dart';
import 'doctor.dart';
import 'shift.dart';

class ScoredRoster {
  Roster roster;
  double totalScore;
  double hoursStdevScore;
  double weekendCallsStdevScore;
  double weekdayCallsStdevScore;
  double weekdayCaesarCoverStdevScore;
  double weekdaySecondOnCallStdevScore;
  double meanCallSpreadScore;
  double meanCallSpreadStdevScore;
  double callSpreadStdevScore;

  ScoredRoster(
    this.roster,
    this.totalScore, [
    this.hoursStdevScore = 0,
    this.weekendCallsStdevScore = 0,
    this.weekdayCallsStdevScore = 0,
    this.weekdayCaesarCoverStdevScore = 0,
    this.weekdaySecondOnCallStdevScore = 0,
    this.meanCallSpreadScore = 0,
    this.meanCallSpreadStdevScore = 0,
    this.callSpreadStdevScore = 0,
  ]);

  @override
  String toString() {
    return 'ScoredRoster(roster: $roster, totalScore: $totalScore, hoursStdevScore: $hoursStdevScore, weekendCallsStdevScore: $weekendCallsStdevScore, weekdayCallsStdevScore: $weekdayCallsStdevScore, weekdayCaesarCoverStdevScore: $weekdayCaesarCoverStdevScore, weekdaySecondOnCallStdevScore: $weekdaySecondOnCallStdevScore, meanCallSpreadScore: $meanCallSpreadScore, meanCallSpreadStdevScore: $meanCallSpreadStdevScore, callSpreadStdevScore: $callSpreadStdevScore)';
  }
}

class AssignmentGenerator {
  final Map<String, double> hoursPerShiftType;
  final double maxOvertimeHours;
  final bool postCallBeforeLeave;

  AssignmentGenerator({
    this.hoursPerShiftType = const {
      'Overnight Weekday': 16,
      'Caesar Cover Weekday': 16,
      'Second On Call Weekday': 16,
      'Day Weekend': 12,
      'Overnight Weekend': 12,
      'Caesar Cover Weekend': 12,
    },
    this.maxOvertimeHours = 90,
    this.postCallBeforeLeave = true,
  }) {
    assert(hoursPerShiftType.isNotEmpty);
    assert(maxOvertimeHours > 0);
  }

  /// Given a set of rosters and a number of retries, this function will attempt to
  /// fill the rosters with valid assignments. If no valid assignments are found
  /// after the given number of retries, the function will return false.
  /// Otherwise, the function will return true and update the rosters, ordered by
  /// the best score found.
  /// The progressNotifier is used to update the progress of the function.
  /// The function will return false if less than 10% of the roster permutations
  /// were valid.
  /// The function will return true if at least one valid roster permutation was found.
  ///
  /// Parameters:
  /// - doctors: The list of doctors to assign to the rosters
  /// - shifts: The list of shifts to assign to the rosters
  /// - retries: The number of candidate rosters to generate
  /// - progressNotifier: A ValueNotifier to update the progress of the function
  /// - outputs: The number of top rosters to return
  ///
  /// Returns:
  /// - A Future<List<Roster>> containing the top roster permutations found
  ///
  /// Example:
  /// ```dart
  /// List<Doctor> doctors = [
  ///   Doctor(name: 'Dr. A', canPerformAnaesthetics: true, canPerformCaesars: true),
  ///   Doctor(name: 'Dr. B', canPerformAnaesthetics: true, canPerformCaesars: true),
  ///   Doctor(name: 'Dr. C', canPerformAnaesthetics: true, canPerformCaesars: true),
  ///   Doctor(name: 'Dr. D', canPerformAnaesthetics: true, canPerformCaesars: true),
  ///   Doctor(name: 'Dr. E', canPerformAnaesthetics: true, canPerformCaesars: true),
  /// ];
  /// List<Shift> shifts = [
  ///   Shift(date: DateTime(2022, 1, 1), type: 'Weekday'),
  ///   Shift(date: DateTime(2022, 1, 2), type: 'Weekend')
  /// ];
  /// AssignmentGenerator generator = AssignmentGenerator();
  /// ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  /// Future<List<Roster>> topRosters = generator.retryAssignments(doctors, shifts, 100, progressNotifier);
  /// ```
  ///
  /// See also:
  /// - [Roster]
  /// - [Doctor]
  /// - [Shift]
  /// - [ValueNotifier]
  /// - [Future]
  /// - [bool]
  Future<List<Roster>> retryAssignments(List<Doctor> doctors,
      List<Shift> shifts, int retries, ValueNotifier<double> progressNotifier,
      [int outputs = 10]) async {
    List<ScoredRoster> topScoredRosters = List.generate(
        outputs,
        (_) => ScoredRoster(
            Roster(doctors: doctors, shifts: shifts), double.infinity));
    int validRostersFound = 0;

    Roster candidateRoster = Roster(doctors: doctors, shifts: shifts);
    for (int i = 0; i < retries; i++) {
      progressNotifier.value = (i + 1) / retries;
      await Future.delayed(const Duration(microseconds: 1));

      candidateRoster.clearAssignments();
      bool filled = assignShifts(candidateRoster);

      if (filled) {
        validRostersFound++;
        double score = _calculateScoreDetailed(candidateRoster).totalScore;
        if (score < topScoredRosters[outputs - 1].totalScore) {
          topScoredRosters[outputs - 1] =
              ScoredRoster(candidateRoster.copy(), score);
          topScoredRosters.sort((a, b) => a.totalScore.compareTo(b.totalScore));
        }
      }
    }

    if (validRostersFound == 0) {
      return [];
    } else {
      if (validRostersFound / retries < 0.1) {
        print('< 10% of roster permutations were valid');
      }
      List<ScoredRoster> detailedScores = topScoredRosters
          .map((scoredRoster) => _calculateScoreDetailed(scoredRoster.roster))
          .toList();
      print(detailedScores);
      return topScoredRosters
          .map((scoredRoster) => scoredRoster.roster)
          .toList();
    }
  }

  bool assignShiftsMultipleRosters(List<Roster> rosters) {
    for (Roster roster in rosters) {
      roster.clearAssignments();
      bool filled = assignShifts(roster);
      if (!filled) {
        return false;
      }
    }
    return true;
  }

  bool assignShifts(Roster roster) {
    roster.shifts.sort((a, b) => a.date.compareTo(b.date));

    for (Shift shift in roster.shifts) {
      int comboFindingAttempts = 0;
      bool valid = false;
      while (comboFindingAttempts < 100 && !valid) {
        if (shift.type == 'Weekday') {
          _assignWeekdayShift(shift, roster);
        } else {
          _assignHolidayOrWeekendShift(shift, roster);
        }

        if (shift.fullyStaffed()) {
          valid = true;
        }

        comboFindingAttempts++;
      }
      if (!valid) {
        roster.filled = false;
        return false;
      }
    }
    roster.filled = true;
    return true;
  }

  void _assignWeekdayShift(Shift shift, Roster roster) {
    Doctor? mainDoctor = roster.getAvailableDoctors('main', shift.date)?.first;
    Doctor? caesarCoverDoctor = roster
        .getAvailableDoctors('caesarCover', shift.date, [mainDoctor])?.first;
    Doctor? secondOnCallDoctor = roster
        .getAvailableDoctors('secondOnCall', shift.date, [mainDoctor])?.first;

    if (mainDoctor != null &&
        caesarCoverDoctor != null &&
        secondOnCallDoctor != null &&
        mainDoctor != secondOnCallDoctor) {
      if (mainDoctor.canPerformAnaesthetics &&
          caesarCoverDoctor.canPerformCaesars) {
        shift.caesarCoverDoctor = caesarCoverDoctor;
        shift.secondOnCallDoctor = caesarCoverDoctor;
      } else if (mainDoctor.canPerformCaesars &&
          caesarCoverDoctor.canPerformAnaesthetics) {
        shift.caesarCoverDoctor = caesarCoverDoctor;
        shift.secondOnCallDoctor = caesarCoverDoctor;
      } else {
        shift.caesarCoverDoctor = caesarCoverDoctor;
        shift.secondOnCallDoctor = secondOnCallDoctor;
      }
      shift.mainDoctor = mainDoctor;

      _updateDoctorOvertime(mainDoctor, 'Overnight Weekday');
      _updateDoctorOvertime(caesarCoverDoctor, 'Caesar Cover Weekday');
      if (secondOnCallDoctor != caesarCoverDoctor) {
        _updateDoctorOvertime(secondOnCallDoctor, 'Second On Call Weekday');
      }
    } else {
      // Handle error: Not enough doctors available
      print('Not enough doctors available for ${shift.date}');
      print('Main Doctor: ${mainDoctor?.name}');
      print('Caesar Cover Doctor: ${caesarCoverDoctor?.name}');
      print('Second On Call Doctor: ${secondOnCallDoctor?.name}');
    }
  }

  void _assignHolidayOrWeekendShift(Shift shift, Roster roster) {
    DateTime nextDay = shift.date.add(const Duration(days: 1));
    bool isWeekendPair = (shift.date.weekday == DateTime.saturday) &&
        nextDay.weekday == DateTime.sunday;

    // if shift already assigned, return
    if (shift.fullyStaffed()) return;

    List<Doctor> dayShiftDoctors =
        roster.findAvailableDoctorsForDayShift(shift.date, nextDay);
    Doctor? nightShiftDoctor = roster.getAvailableDoctors('night', shift.date, [
      ...dayShiftDoctors,
    ])?.first;
    Doctor? caesarCoverDoctor = roster.getAvailableDoctors(
        'caesarCover',
        shift.date,
        [nightShiftDoctor, dayShiftDoctors[0], dayShiftDoctors[1]])?.first;

    if (dayShiftDoctors.length == 2 &&
        nightShiftDoctor != null &&
        caesarCoverDoctor != null) {
      // Make day shift doctors complement each other
      // and use whoever complements the night shift doctor do caesar cover
      if (dayShiftDoctors[0].canPerformAnaesthetics &&
          dayShiftDoctors[1].canPerformCaesars) {
        if (nightShiftDoctor.canPerformCaesars) {
          shift.caesarCoverDoctor = dayShiftDoctors[0];
          shift.weekendDayDoctor = dayShiftDoctors[0];
          shift.secondOnCallDoctor = dayShiftDoctors[1];
        } else {
          shift.caesarCoverDoctor = dayShiftDoctors[1];
          shift.weekendDayDoctor = dayShiftDoctors[1];
          shift.secondOnCallDoctor = dayShiftDoctors[0];
        }
      } else if (dayShiftDoctors[0].canPerformCaesars &&
          dayShiftDoctors[1].canPerformAnaesthetics) {
        if (nightShiftDoctor.canPerformAnaesthetics) {
          shift.caesarCoverDoctor = dayShiftDoctors[0];
          shift.weekendDayDoctor = dayShiftDoctors[0];
          shift.secondOnCallDoctor = dayShiftDoctors[1];
        } else {
          shift.caesarCoverDoctor = dayShiftDoctors[1];
          shift.weekendDayDoctor = dayShiftDoctors[1];
          shift.secondOnCallDoctor = dayShiftDoctors[0];
        }
      } else {
        // Day shift doctors cannot complement each other
        return;
      }
      shift.mainDoctor = nightShiftDoctor;

      _updateDoctorOvertime(shift.weekendDayDoctor!, 'Day Weekend');
      _updateDoctorOvertime(shift.secondOnCallDoctor!, 'Day Weekend');
      _updateDoctorOvertime(shift.mainDoctor!, 'Overnight Weekend');
      _updateDoctorOvertime(shift.caesarCoverDoctor!, 'Caesar Cover Weekend');

      Shift lastShift = roster.shifts[roster.shifts.length - 1];
      if (isWeekendPair && shift != lastShift) {
        Shift nextDayShift = roster.shifts.firstWhere(
          (s) => isSameDate(s.date, nextDay),
        );
        nextDayShift.weekendDayDoctor = shift.weekendDayDoctor!;
        nextDayShift.secondOnCallDoctor = shift.secondOnCallDoctor!;
        nextDayShift.caesarCoverDoctor = shift.caesarCoverDoctor!;
        nextDayShift.mainDoctor = shift.mainDoctor!;

        _updateDoctorOvertime(nextDayShift.weekendDayDoctor!, 'Day Weekend');
        _updateDoctorOvertime(nextDayShift.secondOnCallDoctor!, 'Day Weekend');
        _updateDoctorOvertime(nextDayShift.mainDoctor!, 'Overnight Weekend');
        _updateDoctorOvertime(
            nextDayShift.caesarCoverDoctor!, 'Caesar Cover Weekend');
      }
    } else {
      // Handle error: Not enough doctors available
      print('Not enough doctors available for ${shift.date}');
    }
  }

  // Helper function to compare dates only (ignoring time)
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _updateDoctorOvertime(Doctor doctor, String shiftType) {
    doctor.overtimeHours += hoursPerShiftType[shiftType]!;
    if (shiftType.contains('Weekday')) {
      if (shiftType.contains('Overnight')) {
        doctor.overnightWeekdayCalls++;
      } else if (shiftType.contains('Caesar')) {
        doctor.caesarCoverWeekdayCalls++;
      } else if (shiftType.contains('Second')) {
        doctor.secondOnCallWeekdayCalls++;
      }
    } else if (shiftType.contains('Weekend')) {
      if (shiftType.contains('Caesar')) {
        doctor.caesarCoverWeekendCalls++;
      } else {
        doctor.weekendCalls++;
      }
    }
  }

  num _calculateWeekendCallsStdev(Roster roster) {
    // Calculate the standard deviation of the weekend / PH calls among doctors
    double meanWeekendCalls =
        roster.doctors.fold(0.0, (sum, doctor) => sum + doctor.weekendCalls) /
            roster.doctors.length;
    num weekendCallsStdev = pow(
        roster.doctors.fold(
                0.0,
                (sum, doctor) =>
                    sum + pow(doctor.weekendCalls - meanWeekendCalls, 2)) /
            roster.doctors.length,
        0.5);

    // Normalize the standard deviation by the number of weekend days
    int weekendDays = 0;
    for (Shift shift in roster.shifts) {
      if (shift.type == 'Weekend' || shift.type == 'Holiday') {
        weekendDays++;
      }
    }

    if (weekendDays != 0) {
      weekendCallsStdev /= weekendDays;
    }

    return weekendCallsStdev;
  }

  num _calculateHoursStdev(Roster roster) {
    // Calculate the standard deviation of overtime hours among doctors
    double meanHours =
        roster.doctors.fold(0.0, (sum, doctor) => sum + doctor.overtimeHours) /
            roster.doctors.length;
    num hoursStdev = pow(
        roster.doctors.fold(
                0.0,
                (sum, doctor) =>
                    sum + pow(doctor.overtimeHours - meanHours, 2)) /
            roster.doctors.length,
        0.5);

    hoursStdev /= maxOvertimeHours;

    return hoursStdev;
  }

  // Calculate the standard deviation of weekday calls among doctors
  num _calculateWeekdayCallsStdev(Roster roster, int weekendDays) {
    double meanWeekdayCalls = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.overnightWeekdayCalls +
                doctor.caesarCoverWeekdayCalls +
                doctor.secondOnCallWeekdayCalls) /
        roster.doctors.length;

    num weekdayCallsStdev = pow(
        roster.doctors.fold(
                0.0,
                (sum, doctor) =>
                    sum +
                    pow(
                        doctor.overnightWeekdayCalls +
                            doctor.caesarCoverWeekdayCalls +
                            doctor.secondOnCallWeekdayCalls -
                            meanWeekdayCalls,
                        2)) /
            roster.doctors.length,
        0.5);

    weekdayCallsStdev /= 30 - weekendDays;
    return weekdayCallsStdev;
  }

// Calculate the standard deviation of weekday Caesar Cover calls among doctors
  num _calculateCaesarCoverStdev(Roster roster, int weekendDays) {
    double meanCaesarCoverCalls = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.caesarCoverWeekdayCalls +
                doctor.caesarCoverWeekendCalls) /
        roster.doctors.length;

    num weekdayCaesarCoverStdev = pow(
        roster.doctors.fold(
                0.0,
                (sum, doctor) =>
                    sum +
                    pow(
                        doctor.caesarCoverWeekdayCalls +
                            doctor.caesarCoverWeekendCalls -
                            meanCaesarCoverCalls,
                        2)) /
            roster.doctors.length,
        0.5);

    weekdayCaesarCoverStdev /= 30 - weekendDays;
    return weekdayCaesarCoverStdev;
  }

// Calculate the standard deviation of weekday Second On Call calls among doctors
  num _calculateSecondOnCallStdev(Roster roster, int weekendDays) {
    double meanSecondOnCallCalls = roster.doctors
            .fold(0.0, (sum, doctor) => sum + doctor.secondOnCallWeekdayCalls) /
        roster.doctors.length;

    num weekdaySecondOnCallStdev = pow(
        roster.doctors.fold(
                0.0,
                (sum, doctor) =>
                    sum +
                    pow(doctor.secondOnCallWeekdayCalls - meanSecondOnCallCalls,
                        2)) /
            roster.doctors.length,
        0.5);

    weekdaySecondOnCallStdev /= 30 - weekendDays;
    return weekdaySecondOnCallStdev;
  }

// Calculate the spread of calls over the month for each doctor
  List<num> _calculateDoctorsCallSpreadStdevs(Roster roster) {
    List<num> doctorsCallSpreadStdevs = [];
    for (Doctor doctor in roster.doctors) {
      List<DateTime> callDates = [];
      for (Shift shift in roster.shifts) {
        if (shift.mainDoctor == doctor ||
            shift.caesarCoverDoctor == doctor ||
            shift.secondOnCallDoctor == doctor ||
            shift.weekendDayDoctor == doctor) {
          callDates.add(shift.date);
        }
      }
      callDates.sort();
      List<int> doctorCallSpreads = [];
      for (int i = 1; i < callDates.length; i++) {
        doctorCallSpreads.add(callDates[i].difference(callDates[i - 1]).inDays);
      }
      double doctorMeanCallSpread =
          doctorCallSpreads.fold(0, (sum, spread) => sum + spread) /
              doctorCallSpreads.length;
      doctorsCallSpreadStdevs.add(pow(
          doctorCallSpreads.fold(
                  0.0,
                  (sum, spread) =>
                      sum + pow(spread - doctorMeanCallSpread, 2)) /
              doctorCallSpreads.length,
          0.5));
    }
    return doctorsCallSpreadStdevs;
  }

// Calculate the mean call spread for each doctor
  List<double> _calculateDoctorsMeanCallSpreads(Roster roster) {
    List<double> doctorsMeanCallSpreads = [];
    for (Doctor doctor in roster.doctors) {
      List<DateTime> callDates = [];
      for (Shift shift in roster.shifts) {
        if (shift.mainDoctor == doctor ||
            shift.caesarCoverDoctor == doctor ||
            shift.secondOnCallDoctor == doctor ||
            shift.weekendDayDoctor == doctor) {
          callDates.add(shift.date);
        }
      }
      callDates.sort();
      List<int> doctorCallSpreads = [];
      for (int i = 1; i < callDates.length; i++) {
        doctorCallSpreads.add(callDates[i].difference(callDates[i - 1]).inDays);
      }
      double doctorMeanCallSpread =
          doctorCallSpreads.fold(0, (sum, spread) => sum + spread) /
              doctorCallSpreads.length;
      doctorsMeanCallSpreads.add(doctorMeanCallSpread);
    }
    return doctorsMeanCallSpreads;
  }

// Calculate the maximum possible spread of calls over the roster
  double _calculateMaxSpread(Roster roster) {
    int weekendDays = _calculateWeekendDays(roster);
    int rolesPerShiftWeekend = 4;
    int rolesPerShiftWeekday = 3;
    int totalRoles = rolesPerShiftWeekend * weekendDays +
        rolesPerShiftWeekday * (30 - weekendDays);
    double rolesPerShift = totalRoles / roster.doctors.length;
    double maxSpread = totalRoles / (roster.doctors.length * rolesPerShift);
    return maxSpread;
  }

// Calculate the spread of calls over the month for each doctor
  double _calculateMeanDoctorsCallSpreadStdev(
      List<num> doctorsCallSpreadStdevs) {
    double meanDoctorsCallSpreadStdev =
        doctorsCallSpreadStdevs.fold(0.0, (sum, stdev) => sum + stdev) /
            doctorsCallSpreadStdevs.length;
    return meanDoctorsCallSpreadStdev;
  }

// Calculate the mean call spread
  double _calculateMeanCallSpread(
      List<double> doctorsMeanCallSpreads, double maxSpread) {
    double meanDoctorsMeanCallSpread =
        doctorsMeanCallSpreads.fold(0.0, (sum, spread) => sum + spread) /
            doctorsMeanCallSpreads.length;
    double meanCallSpread = (maxSpread - meanDoctorsMeanCallSpread) / maxSpread;
    return meanCallSpread;
  }

// Calculate the standard deviation of the mean call spreads
  num _calculateMeanCallSpreadStdev(
      List<double> doctorsMeanCallSpreads, double meanDoctorsMeanCallSpread) {
    num meanCallSpreadStdev = pow(
        doctorsMeanCallSpreads.fold(
                0.0,
                (sum, meanSpread) =>
                    sum + pow(meanSpread - meanDoctorsMeanCallSpread, 2)) /
            doctorsMeanCallSpreads.length,
        0.5);
    return meanCallSpreadStdev;
  }

// Calculate the standard deviation of call spread
  num _calculateCallSpreadStdev(List<num> doctorsCallSpreadStdevs,
      double meanDoctorsCallSpreadStdev, double maxSpread) {
    num callSpreadStdev = pow(
        doctorsCallSpreadStdevs.fold(
                0.0,
                (sum, stdev) =>
                    sum + pow(stdev - meanDoctorsCallSpreadStdev, 2)) /
            doctorsCallSpreadStdevs.length,
        0.5);
    callSpreadStdev = callSpreadStdev / maxSpread;
    return callSpreadStdev;
  }

  int _calculateWeekendDays(Roster roster) {
    return roster.shifts
        .where((shift) => shift.type == 'Weekend' || shift.type == 'Holiday')
        .length;
  }

  ScoredRoster _calculateScoreDetailed(Roster roster,
      [double hoursStdevWeight = 50.0,
      double weekendCallsStdevWeight = 1.0,
      double weekdayCallsStdevWeight = 1.0,
      double weekdayCaesarCoverStdevWeight = 1.0,
      double weekdaySecondOnCallStdevWeight = 1.0,
      double meanCallSpreadWeight = 0.0,
      double meanCallSpreadStdevWeight = 1.0,
      double callSpreadStdevWeight = 1.0]) {
    num weekendCallsStdev = _calculateWeekendCallsStdev(roster);
    num hoursStdev = _calculateHoursStdev(roster);

    int weekendDays = _calculateWeekendDays(roster);

    num weekdayCallsStdev = _calculateWeekdayCallsStdev(roster, weekendDays);
    num weekdayCaesarCoverStdev =
        _calculateCaesarCoverStdev(roster, weekendDays);
    num weekdaySecondOnCallStdev =
        _calculateSecondOnCallStdev(roster, weekendDays);

    List<num> doctorsCallSpreadStdevs =
        _calculateDoctorsCallSpreadStdevs(roster);
    List<double> doctorsMeanCallSpreads =
        _calculateDoctorsMeanCallSpreads(roster);

    double maxSpread = _calculateMaxSpread(roster);

    double meanDoctorsCallSpreadStdev =
        _calculateMeanDoctorsCallSpreadStdev(doctorsCallSpreadStdevs);
    double meanCallSpread =
        _calculateMeanCallSpread(doctorsMeanCallSpreads, maxSpread);

    double meanDoctorsMeanCallSpread =
        doctorsMeanCallSpreads.fold(0.0, (sum, spread) => sum + spread) /
            doctorsMeanCallSpreads.length;
    num meanCallSpreadStdev = _calculateMeanCallSpreadStdev(
        doctorsMeanCallSpreads, meanDoctorsMeanCallSpread);

    num callSpreadStdev = _calculateCallSpreadStdev(
        doctorsCallSpreadStdevs, meanDoctorsCallSpreadStdev, maxSpread);

    double hoursStdevScore = hoursStdevWeight * hoursStdev;
    double weekendCallsStdevScore = weekendCallsStdevWeight * weekendCallsStdev;
    double weekdayCallsStdevScore = weekdayCallsStdevWeight * weekdayCallsStdev;
    double weekdayCaesarCoverStdevScore =
        weekdayCaesarCoverStdevWeight * weekdayCaesarCoverStdev;
    double weekdaySecondOnCallStdevScore =
        weekdaySecondOnCallStdevWeight * weekdaySecondOnCallStdev;
    double meanCallSpreadScore = meanCallSpreadWeight * meanCallSpread;
    double meanCallSpreadStdevScore =
        meanCallSpreadStdevWeight * meanCallSpreadStdev;
    double callSpreadStdevScore = callSpreadStdevWeight * callSpreadStdev;

    double totalScore = hoursStdevScore +
        weekendCallsStdevScore +
        weekdayCallsStdevScore +
        weekdayCaesarCoverStdevScore +
        weekdaySecondOnCallStdevScore +
        meanCallSpreadScore +
        meanCallSpreadStdevScore +
        callSpreadStdevScore;

    return ScoredRoster(
        roster,
        totalScore,
        hoursStdevScore,
        weekendCallsStdevScore,
        weekdayCallsStdevScore,
        weekdayCaesarCoverStdevScore,
        weekdaySecondOnCallStdevScore,
        meanCallSpreadScore,
        meanCallSpreadStdevScore,
        callSpreadStdevScore);
  }

  AssignmentGenerator copy() {
    return AssignmentGenerator(
      hoursPerShiftType: hoursPerShiftType,
      maxOvertimeHours: maxOvertimeHours,
      postCallBeforeLeave: postCallBeforeLeave,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! AssignmentGenerator) return false;

    return other.hoursPerShiftType == hoursPerShiftType &&
        other.maxOvertimeHours == maxOvertimeHours &&
        other.postCallBeforeLeave == postCallBeforeLeave;
  }

  @override
  int get hashCode {
    return hoursPerShiftType.hashCode ^
        maxOvertimeHours.hashCode ^
        postCallBeforeLeave.hashCode;
  }
}
