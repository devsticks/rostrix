import 'package:flutter/material.dart';
import 'dart:math';
import 'roster.dart';
import 'doctor.dart';
import 'shift.dart';

class ScoredRoster {
  double score;
  Roster roster;

  ScoredRoster(this.score, this.roster);
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
            double.infinity, Roster(doctors: doctors, shifts: shifts)));
    int validRostersFound = 0;

    Roster candidateRoster = Roster(doctors: doctors, shifts: shifts);
    for (int i = 0; i < retries; i++) {
      progressNotifier.value = (i + 1) / retries;
      await Future.delayed(const Duration(microseconds: 1));

      candidateRoster.clearAssignments();
      bool filled = assignShifts(candidateRoster);

      if (filled) {
        validRostersFound++;
        double score = _calculateScore(candidateRoster);
        if (score < topScoredRosters[outputs - 1].score) {
          topScoredRosters[outputs - 1] =
              ScoredRoster(score, candidateRoster.copy());
          topScoredRosters.sort((a, b) => a.score.compareTo(b.score));
        }
      }
    }

    if (validRostersFound == 0) {
      return [];
    } else {
      if (validRostersFound / retries < 0.1) {
        print('< 10% of roster permutations were valid');
      }
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

  double _calculateScore(Roster roster,
      [double hoursVarianceWeight = 1.0,
      double weekendCallsVarianceWeight = 1.0,
      double weekdayCallsVarianceWeight = 1.0,
      double weekdayCaesarCoverVarianceWeight = 1.0,
      double weekdaySecondOnCallVarianceWeight = 1.0,
      double callSpreadWeight = 1.0]) {
    // Calculate the variance of the weekend / PH calls among doctors
    double meanWeekendCalls =
        roster.doctors.fold(0.0, (sum, doctor) => sum + doctor.weekendCalls) /
            roster.doctors.length;
    double weekendCallsVariance = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum + pow(doctor.weekendCalls - meanWeekendCalls, 2)) /
        roster.doctors.length;

    // Normalize the variance by the number of weekend days
    int weekendDays = 0;
    for (Shift shift in roster.shifts) {
      if (shift.type == 'Weekend' || shift.type == 'Holiday') {
        weekendDays++;
      }
    }

    if (weekendDays != 0) {
      weekendCallsVariance /= weekendDays;
    }

    // Calculate the variance of overtime hours among doctors
    double meanHours =
        roster.doctors.fold(0.0, (sum, doctor) => sum + doctor.overtimeHours) /
            roster.doctors.length;
    double hoursVariance = roster.doctors.fold(0.0,
            (sum, doctor) => sum + pow(doctor.overtimeHours - meanHours, 2)) /
        roster.doctors.length;

    hoursVariance /= maxOvertimeHours;

    // Calculate the variance of weekday calls among doctors
    double meanWeekdayCalls = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.overnightWeekdayCalls +
                doctor.caesarCoverWeekdayCalls +
                doctor.secondOnCallWeekdayCalls) /
        roster.doctors.length;

    double weekdayCallsVariance = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(
                    doctor.overnightWeekdayCalls +
                        doctor.caesarCoverWeekdayCalls +
                        doctor.secondOnCallWeekdayCalls -
                        meanWeekdayCalls,
                    2)) /
        roster.doctors.length;

    weekdayCallsVariance /= 30 - weekendDays;

    // Calculate the variance of weekday Caesar Cover calls among doctors
    double meanCaesarCoverCalls = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.caesarCoverWeekdayCalls +
                doctor.caesarCoverWeekendCalls) /
        roster.doctors.length;

    double weekdayCaesarCoverVariance = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(
                    doctor.caesarCoverWeekdayCalls +
                        doctor.caesarCoverWeekendCalls -
                        meanCaesarCoverCalls,
                    2)) /
        roster.doctors.length;

    weekdayCaesarCoverVariance /= 30 - weekendDays;

    // Calculate the variance of weekday Second On Call calls among doctors
    double meanSecondOnCallCalls = roster.doctors
            .fold(0.0, (sum, doctor) => sum + doctor.secondOnCallWeekdayCalls) /
        roster.doctors.length;

    double weekdaySecondOnCallVariance = roster.doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(doctor.secondOnCallWeekdayCalls - meanSecondOnCallCalls,
                    2)) /
        roster.doctors.length;

    weekdaySecondOnCallVariance /= 30 - weekendDays;

    // Calculate the spread of calls over the month for each doctor (ideally want them as evenly-spaced as possible)
    // This is a matter of maximising the space between each call for each doctor - larger is better
    double callSpread = 0.0;
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
      for (int i = 1; i < callDates.length; i++) {
        callSpread += callDates[i].difference(callDates[i - 1]).inDays;
      }
    }

    // Normalize the call spread, and to make it a score, subtract it from 1
    double maxSpread = 30 * roster.shifts.length / roster.doctors.length;
    callSpread = 1 - (callSpread / maxSpread);

    return hoursVarianceWeight * hoursVariance +
        weekendCallsVarianceWeight * weekendCallsVariance +
        weekdayCallsVarianceWeight * weekdayCallsVariance +
        weekdayCaesarCoverVarianceWeight * weekdayCaesarCoverVariance +
        weekdaySecondOnCallVarianceWeight * weekdaySecondOnCallVariance +
        callSpreadWeight * callSpread;
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
