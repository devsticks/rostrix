import 'dart:math';
import 'doctor.dart';
import 'shift.dart';

class Roster {
  List<Doctor> doctors;
  List<Shift> shifts;
  Map<String, double> hoursPerShiftType;
  double maxOvertimeHours;
  bool postCallBeforeLeave;
  bool filled = true;

  Roster({
    required this.doctors,
    required this.shifts,
    required this.hoursPerShiftType,
    this.maxOvertimeHours = 90,
    this.postCallBeforeLeave = true,
  });

  void assignShifts() {
    shifts.sort((a, b) =>
        a.date.compareTo(b.date)); // Ensure shifts are in chronological order

    for (Shift shift in shifts) {
      // Attempt combinations until a valid one is found
      int comboFindingAttempts = 0;
      bool valid = false;
      while (comboFindingAttempts < 100 && !valid) {
        if (shift.type == 'Weekday') {
          _assignWeekdayShift(shift);
        } else {
          _assignHolidayOrWeekendShift(shift);
        }

        if (shift.mainDoctor != null &&
            shift.caesarCoverDoctor != null &&
            shift.secondOnCallDoctor != null) {
          valid = true;
        }

        comboFindingAttempts++;
      }
      if (!valid) {
        filled = false;
        break;
      }
    }
  }

  void _assignWeekdayShift(Shift shift) {
    Doctor? mainDoctor = _findAvailableDoctor('main', shift.date);
    Doctor? caesarCoverDoctor =
        _findAvailableDoctor('caesarCover', shift.date, [mainDoctor]);
    Doctor? secondOnCallDoctor =
        _findAvailableDoctor('secondOnCall', shift.date, [mainDoctor]);

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

  void _assignHolidayOrWeekendShift(Shift shift) {
    DateTime nextDay = shift.date.add(Duration(days: 1));
    bool isWeekendPair = (shift.date.weekday == DateTime.saturday) &&
        nextDay.weekday == DateTime.sunday;

    // if shift already assigned, return
    if (shift.fullyStaffed()) return;

    List<Doctor> dayShiftDoctors =
        _findAvailableDoctorsForDayShift(shift.date, nextDay);
    Doctor? nightShiftDoctor = _findAvailableDoctor('night', shift.date, [
      ...dayShiftDoctors,
    ]);
    Doctor? caesarCoverDoctor = _findAvailableDoctor('caesarCover', shift.date,
        [nightShiftDoctor, dayShiftDoctors[0], dayShiftDoctors[1]]);

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

      Shift lastShift = shifts[shifts.length - 1];
      if (isWeekendPair && shift != lastShift) {
        Shift nextDayShift = shifts.firstWhere((s) => s.date == nextDay);
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

  Doctor? _findAvailableDoctor(String role, DateTime date,
      [List<Doctor?>? avoidDoctors]) {
    List<Doctor> availableDoctors = doctors.where((doctor) {
      return _isDoctorAvailable(doctor, role, date, avoidDoctors);
    }).toList();

    if (availableDoctors.isEmpty) return null;

    // only pick from doctors about to go on leave if postCallBeforeLeave enabled
    List<Doctor> preLeaveDoctors = [];
    if (postCallBeforeLeave) {
      preLeaveDoctors = availableDoctors
          .where((doc) =>
              doc.getExpandedLeaveDays().isNotEmpty &&
              doc.getExpandedLeaveDays()[0].difference(date).inDays == 1)
          .toList();
    }
    if (preLeaveDoctors.isNotEmpty) availableDoctors = preLeaveDoctors;

    // Add randomness
    availableDoctors.shuffle(Random());

    // For weekends, sort by fewest weekend / PH calls
    if (role.contains('Weekend')) {
      availableDoctors.sort((a, b) {
        return a.weekendCalls.compareTo(b.weekendCalls);
      });
    }

    return availableDoctors.first;
  }

  List<Doctor> _findAvailableDoctorsForDayShift(DateTime date,
      [DateTime? nextDay]) {
    List<Doctor> availableDoctors = doctors.where((doctor) {
      return _isDoctorAvailable(doctor, 'day', date);
    }).toList();

    // If ensuring same doctors for Saturday and Sunday, check availability for both days
    if (nextDay != null) {
      availableDoctors = availableDoctors.where((doctor) {
        return _isDoctorAvailable(doctor, 'day', nextDay);
      }).toList();
    }

    // Add randomness
    availableDoctors.shuffle(Random());

    // Sort by fewest weekend / PH calls
    availableDoctors.sort((a, b) {
      return a.weekendCalls.compareTo(b.weekendCalls);
    });

    return availableDoctors.length > 2
        ? availableDoctors.sublist(0, 2)
        : availableDoctors;
  }

  bool _isDoctorAvailable(Doctor doctor, String role, DateTime date,
      [List<Doctor?>? avoidDoctors]) {
    List<DateTime> leaveDays = doctor.getExpandedLeaveDays();

    // Check if the doctor is on leave (or if this is a Friday/weekend/holiday contiguous to a leave block)
    if (leaveDays.contains(date)) return false;

    // If post-call before leave is enabled, give at least 3 nights' leeway before that call,
    // but show the doctor as available for that last day
    const int daysBeforeLastCall = 3;
    if (postCallBeforeLeave && leaveDays.isNotEmpty) {
      for (DateTime leaveDay in leaveDays) {
        DateTime previousDay = leaveDay.subtract(const Duration(days: 1));

        bool isStartOfLeaveBlock = !leaveDays.contains(
            previousDay); // is current leaveDay the start of a leave block

        if (isStartOfLeaveBlock &&
            leaveDay.difference(date).inDays > 0 && // leaveDay is in the future
            leaveDay.difference(date).inDays <
                daysBeforeLastCall +
                    1 && // leaveDay is within 3 days of this date
            leaveDay.difference(date).inDays != 1) {
          // date is not the day before leave starts
          return false;
        }
      }
    }

    // Check if the doctor is not assigned to another shift on the same date
    for (Shift shift in shifts) {
      if (shift.date == date &&
          (shift.mainDoctor == doctor ||
              shift.caesarCoverDoctor == doctor ||
              shift.secondOnCallDoctor == doctor)) {
        return false;
      }
    }

    // Check if the doctor is not on call the previous night unless it's a weekend
    DateTime prevDate = date.subtract(Duration(days: 1));
    // if (role != 'day') {
    for (Shift shift in shifts) {
      if (shift.date == prevDate &&
          (shift.mainDoctor == doctor ||
              shift.caesarCoverDoctor == doctor ||
              shift.secondOnCallDoctor == doctor ||
              shift.weekendDayDoctor == doctor)) {
        // if (date.weekday != DateTime.saturday) return false;
        return false;
      }
    }
    // }

    // Ensure the main doctor and caesar cover doctor are not the same
    if (role == 'caesarCover' &&
        avoidDoctors != null &&
        avoidDoctors.contains(doctor)) return false;

    // Check specific role capabilities
    if (role == 'caesarCover' && !doctor.canPerformCaesars) return false;
    if (role == 'secondOnCall' && !doctor.canPerformAnaesthetics) return false;

    // Avoid doctor for specific roles if needed
    if (avoidDoctors != null && avoidDoctors.contains(doctor)) return false;

    return true;
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

  void addLeaveDays(Doctor doctor, List<DateTime> leaveDays) {
    doctor.leaveDays.addAll(leaveDays);
  }

  void retryAssignments(int retries) {
    List<Doctor> bestDoctors = [];
    List<Shift> bestShifts = [];
    double bestScore = double.infinity;
    int validRostersFound = 0;

    for (int i = 0; i < retries; i++) {
      // Create deep copies of the doctors and shifts for each retry
      List<Doctor> doctorsCopy = doctors
          .map((d) => Doctor(
              name: d.name,
              canPerformCaesars: d.canPerformCaesars,
              canPerformAnaesthetics: d.canPerformAnaesthetics,
              overtimeHours: 0, // Reset overtime hours for each retry
              overnightWeekdayCalls: 0,
              secondOnCallWeekdayCalls: 0,
              caesarCoverWeekdayCalls: 0,
              weekendCalls: 0,
              leaveDays: List.from(d.leaveDays)))
          .toList();

      List<Shift> shiftsCopy = shifts
          .map((s) => Shift(
              date: s.date,
              type: s.type,
              mainDoctor: null,
              caesarCoverDoctor: null,
              secondOnCallDoctor: null))
          .toList();

      // Create a Roster with the copies
      Roster tempRoster = Roster(
        doctors: doctorsCopy,
        shifts: shiftsCopy,
        hoursPerShiftType: hoursPerShiftType,
        maxOvertimeHours: maxOvertimeHours,
        postCallBeforeLeave: postCallBeforeLeave,
      );

      tempRoster.assignShifts();

      if (tempRoster.filled) {
        // If a valid roster is found, calculate the score
        validRostersFound++;
        double score = tempRoster._calculateScore();
        if (score < bestScore) {
          bestScore = score;
          bestDoctors = doctorsCopy.map((d) => d.copy()).toList();
          bestShifts = shiftsCopy.map((s) => s.copy()).toList();
        }
      }
    }

    if (validRostersFound == 0) {
      print('No valid roster permutations found in $retries tries');
    } else {
      if (validRostersFound / retries < 0.1) {
        print('< 10\% of roster permutations were valid');
      }
      doctors = bestDoctors;
      shifts = bestShifts;
    }
  }

  double _calculateScore(
      [double hoursVarianceWeight = 1.0,
      double weekendCallsVarianceWeight = 1.0,
      double weekdayCallsVarianceWeight = 1.0,
      double weekdayCaesarCoverVarianceWeight = 1.0,
      double weekdaySecondOnCallVarianceWeight = 1.0,
      double callSpreadWeight = 1.0]) {
    // Calculate the variance of the weekend / PH calls among doctors
    double meanWeekendCalls =
        doctors.fold(0.0, (sum, doctor) => sum + doctor.weekendCalls) /
            doctors.length;
    double weekendCallsVariance = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum + pow(doctor.weekendCalls - meanWeekendCalls, 2)) /
        doctors.length;

    // Normalize the variance by the number of weekend days
    int weekendDays = 0;
    for (Shift shift in shifts) {
      if (shift.type == 'Weekend' || shift.type == 'Holiday') {
        weekendDays++;
      }
    }
    weekendCallsVariance /= weekendDays;

    // Calculate the variance of overtime hours among doctors
    double meanHours =
        doctors.fold(0.0, (sum, doctor) => sum + doctor.overtimeHours) /
            doctors.length;
    double hoursVariance = doctors.fold(0.0,
            (sum, doctor) => sum + pow(doctor.overtimeHours - meanHours, 2)) /
        doctors.length;

    hoursVariance /= maxOvertimeHours;

    // Calculate the variance of weekday calls among doctors
    double meanWeekdayCalls = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.overnightWeekdayCalls +
                doctor.caesarCoverWeekdayCalls +
                doctor.secondOnCallWeekdayCalls) /
        doctors.length;

    double weekdayCallsVariance = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(
                    doctor.overnightWeekdayCalls +
                        doctor.caesarCoverWeekdayCalls +
                        doctor.secondOnCallWeekdayCalls -
                        meanWeekdayCalls,
                    2)) /
        doctors.length;

    weekdayCallsVariance /= 30 - weekendDays;

    // Calculate the variance of weekday Caesar Cover calls among doctors
    double meanCaesarCoverCalls = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                doctor.caesarCoverWeekdayCalls +
                doctor.caesarCoverWeekendCalls) /
        doctors.length;

    double weekdayCaesarCoverVariance = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(
                    doctor.caesarCoverWeekdayCalls +
                        doctor.caesarCoverWeekendCalls -
                        meanCaesarCoverCalls,
                    2)) /
        doctors.length;

    weekdayCaesarCoverVariance /= 30 - weekendDays;

    // Calculate the variance of weekday Second On Call calls among doctors
    double meanSecondOnCallCalls = doctors.fold(
            0.0, (sum, doctor) => sum + doctor.secondOnCallWeekdayCalls) /
        doctors.length;

    double weekdaySecondOnCallVariance = doctors.fold(
            0.0,
            (sum, doctor) =>
                sum +
                pow(doctor.secondOnCallWeekdayCalls - meanSecondOnCallCalls,
                    2)) /
        doctors.length;

    weekdaySecondOnCallVariance /= 30 - weekendDays;

    // Calculate the spread of calls over the month for each doctor (ideally want them as evenly-spaced as possible)
    // This is a matter of maximising the space between each call for each doctor - larger is better
    double callSpread = 0.0;
    for (Doctor doctor in doctors) {
      List<DateTime> callDates = [];
      for (Shift shift in shifts) {
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
    double maxSpread = 30 * shifts.length / doctors.length;
    callSpread = 1 - (callSpread / maxSpread);

    return hoursVarianceWeight * hoursVariance +
        weekendCallsVarianceWeight * weekendCallsVariance +
        weekdayCallsVarianceWeight * weekdayCallsVariance +
        weekdayCaesarCoverVarianceWeight * weekdayCaesarCoverVariance +
        weekdaySecondOnCallVarianceWeight * weekdaySecondOnCallVariance +
        callSpreadWeight * callSpread;
  }
}
