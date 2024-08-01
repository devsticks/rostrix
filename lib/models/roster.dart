import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'doctor.dart';
import 'shift.dart';
import 'assignment_generator.dart';
import 'package:open_file/open_file.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class Roster {
  List<Doctor> doctors;
  List<Shift> shifts;
  bool filled;
  final AssignmentGenerator assigner;

  Roster({
    required this.doctors,
    required this.shifts,
    AssignmentGenerator? assigner,
    this.filled = false,
  }) : assigner = assigner ?? AssignmentGenerator();

  Future<bool> retryAssignments(
      int retries, ValueNotifier<double> progressNotifier) async {
    return await assigner.retryAssignments(this, retries, progressNotifier);
  }

  List<Doctor>? getAvailableDoctors(String role, DateTime date,
      [List<Doctor?>? avoidDoctors]) {
    List<Doctor> availableDoctors = doctors.where((doctor) {
      return isDoctorAvailable(doctor, role, date, avoidDoctors);
    }).toList();

    if (availableDoctors.isEmpty) return null;

    // only pick from doctors about to go on leave if postCallBeforeLeave enabled
    List<Doctor> preLeaveDoctors = [];
    if (assigner.postCallBeforeLeave) {
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

    return availableDoctors;
  }

  List<Doctor> findAvailableDoctorsForDayShift(DateTime date,
      [DateTime? nextDay]) {
    List<Doctor> availableDoctors = doctors.where((doctor) {
      return isDoctorAvailable(doctor, 'day', date);
    }).toList();

    // If ensuring same doctors for Saturday and Sunday, check availability for both days
    if (nextDay != null) {
      availableDoctors = availableDoctors.where((doctor) {
        return isDoctorAvailable(doctor, 'day', nextDay);
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

  bool isDoctorAvailable(Doctor doctor, String role, DateTime date,
      [List<Doctor?>? avoidDoctors]) {
    List<DateTime> leaveDays = doctor.getExpandedLeaveDays();

    // Check if the doctor is on leave (or if this is a Friday/weekend/holiday contiguous to a leave block)
    if (leaveDays.contains(date)) return false;

    // If post-call before leave is enabled, give at least 3 nights' leeway before that call,
    // but show the doctor as available for that last day
    const int daysBeforeLastCall = 3;
    if (assigner.postCallBeforeLeave && leaveDays.isNotEmpty) {
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
    DateTime prevDate = date.subtract(const Duration(days: 1));
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

  void addLeaveDays(Doctor doctor, List<DateTime> leaveDays) {
    doctor.leaveDays.addAll(leaveDays);
  }

  String makeCsv() {
    String csv = 'Roster - ${DateFormat('MMM yyyy').format(shifts[0].date)}\n';
    csv += 'Date,Day/Eve (2nd-on-call),Night,CS Cover,Leave\n';
    for (Shift shift in shifts) {
      String mainDoctor =
          shift.mainDoctor != null ? shift.mainDoctor!.name : '';
      String caesarCoverDoctor =
          shift.caesarCoverDoctor != null ? shift.caesarCoverDoctor!.name : '';
      String secondOnCallDoctor = shift.secondOnCallDoctor != null
          ? shift.secondOnCallDoctor!.name
          : '';
      String weekendDayDoctor = shift.weekendDayDoctor != null
          ? '; ${shift.weekendDayDoctor!.name}'
          : '';
      String leaveDoctors = doctors
          .where((doctor) => doctor.leaveDays.contains(shift.date))
          .map((doctor) => doctor.name)
          .join('; ');
      csv +=
          '${DateFormat('EEEE yyyy-MM-dd').format(shift.date)},$secondOnCallDoctor$weekendDayDoctor,$mainDoctor,$caesarCoverDoctor,$leaveDoctors\n';
    }

    csv += '\nSummary\n';
    csv +=
        'Doctor,Total Hours,Weekend / PH,Weekday,2nd On Call (Wk),CS Covers (Wk),CS Covers (Wkend/PH)\n';
    for (Doctor doctor in doctors) {
      csv +=
          '${doctor.name},${doctor.overtimeHours.toStringAsFixed(1)},${doctor.weekendCalls.toStringAsFixed(1)},${doctor.overnightWeekdayCalls.toStringAsFixed(1)},${doctor.secondOnCallWeekdayCalls.toStringAsFixed(1)},${doctor.caesarCoverWeekdayCalls.toStringAsFixed(1)},${doctor.caesarCoverWeekendCalls.toStringAsFixed(1)}\n';
    }

    return csv;
  }

  Future<void> downloadAsCsv(BuildContext context) async {
    final String csv = makeCsv();
    final String suggestedName =
        'Roster ${DateFormat('yyyy-MM').format(shifts[0].date)}.csv';

    if (kIsWeb) {
      // Web-specific code
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", suggestedName)
        ..click();

      html.Url.revokeObjectUrl(url);
    } else {
      // Non-web platform code
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'csv',
        extensions: ['csv'],
      );

      final FileSaveLocation? saveLocation = await getSaveLocation(
        acceptedTypeGroups: [typeGroup],
        suggestedName: suggestedName,
      );

      if (saveLocation == null) {
        // nothing selected
        return;
      }

      try {
        final file = File(saveLocation.path);
        await file.writeAsString(csv);

        // Inform the user that the file has been saved
        print('CSV file saved to: ${saveLocation.path}');

        // Optionally, show a dialog to inform the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('CSV Exported'),
              content:
                  Text('The CSV file has been saved to: ${saveLocation.path}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await OpenFile.open(saveLocation.path);
                  },
                ),
                TextButton(
                  child: const Text('Show Location'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (Platform.isWindows) {
                      await Process.run(
                          'explorer.exe', ['/select,', saveLocation.path]);
                    } else if (Platform.isMacOS) {
                      await Process.run('open', ['-R', saveLocation.path]);
                    } else {
                      // Fallback for other platforms if needed
                      await OpenFile.open(saveLocation.path);
                    }
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error saving CSV file: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to save the CSV file.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void clearAssignments() {
    for (Shift shift in shifts) {
      shift.mainDoctor = null;
      shift.caesarCoverDoctor = null;
      shift.secondOnCallDoctor = null;
      shift.weekendDayDoctor = null;
    }
    for (Doctor doctor in doctors) {
      doctor.overtimeHours = 0;
      doctor.weekendCalls = 0;
      doctor.overnightWeekdayCalls = 0;
      doctor.secondOnCallWeekdayCalls = 0;
      doctor.caesarCoverWeekdayCalls = 0;
      doctor.caesarCoverWeekendCalls = 0;
    }
    filled = false;
  }

  Roster copy() {
    return Roster(
      doctors: doctors.map((doctor) => doctor.copy()).toList(),
      shifts: shifts.map((shift) => shift.copy()).toList(),
      assigner: assigner.copy(),
      filled: filled,
    );
  }

  @override
  String toString() {
    return 'Roster(doctors: $doctors, shifts: $shifts, filled: $filled, assigner: $assigner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Roster) return false;

    return const DeepCollectionEquality().equals(other.doctors, doctors) &&
        const DeepCollectionEquality().equals(other.shifts, shifts) &&
        other.filled == filled &&
        other.assigner == assigner;
  }

  @override
  int get hashCode {
    return const DeepCollectionEquality().hash(doctors) ^
        const DeepCollectionEquality().hash(shifts) ^
        filled.hashCode ^
        assigner.hashCode;
  }
}
