import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../models/shift.dart';
import '../models/roster.dart';
import '../widgets/doctors_summary_table.dart';
import '../widgets/roster_display.dart';
import '../widgets/leave_management.dart';

class RosterHomePage extends StatefulWidget {
  const RosterHomePage({super.key});

  @override
  RosterHomePageState createState() => RosterHomePageState();
}

class RosterHomePageState extends State<RosterHomePage> {
  final ValueNotifier<bool> _postCallBeforeLeaveValueNotifier =
      ValueNotifier<bool>(true);
  List<Doctor> doctors = [];
  List<Shift> shifts = [];
  Map<String, double> hoursPerShiftType = {
    'Overnight Weekday': 16,
    'Second On Call Weekday': 6,
    'Caesar Cover Weekday': 3,
    'Overnight Weekend': 12,
    'Day Weekend': 12,
    'Caesar Cover Weekend': 3.6,
  };
  double maxOvertimeHours = 90;
  int year = 2024;
  int month = 7;

  @override
  void initState() {
    super.initState();
    _initializeDoctorsAndShifts();
  }

  @override
  void dispose() {
    _postCallBeforeLeaveValueNotifier.dispose();
    super.dispose();
  }

  void _initializeDoctorsAndShifts() {
    // Initialize doctors
    doctors = [
      Doctor(
          name: "Anderson",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Bethe",
          canPerformCaesars: true,
          canPerformAnaesthetics: false),
      Doctor(
          name: "Carter",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Davies",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Elliott",
          canPerformCaesars: true,
          canPerformAnaesthetics: false),
      Doctor(
          name: "Fisher",
          canPerformCaesars: true,
          canPerformAnaesthetics: false),
      Doctor(
          name: "Gcilitshana",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Hendricks",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Ibrahim",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Jansen",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Khumalo",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
    ];

    // Initialize shifts for the selected month
    _initializeShifts();
  }

  void _initializeShifts() {
    shifts.clear();
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0);

    for (int i = 0; i < endDate.day; i++) {
      DateTime date = startDate.add(Duration(days: i));
      String type = 'Weekday';
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        type = 'Weekend';
      } else if (_isPublicHoliday(date)) {
        type = 'Holiday';
      }

      shifts.add(Shift(date: date, type: type));
    }
  }

  bool _isPublicHoliday(DateTime date) {
    List<DateTime> publicHolidays = getPublicHolidays(year);
    return publicHolidays.contains(date);
  }

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

  void _assignShifts() {
    Roster roster = Roster(
      doctors: doctors,
      shifts: shifts,
      hoursPerShiftType: hoursPerShiftType,
      maxOvertimeHours: maxOvertimeHours,
    );
    roster.assignShifts();
    setState(() {});
  }

  void _addLeaveDays(Doctor doctor, List<DateTime> leaveDays) {
    setState(() {
      for (DateTime leaveDay in leaveDays) {
        if (!doctor.leaveDays.contains(leaveDay)) {
          doctor.leaveDays.add(leaveDay);
        }
      }
      doctor.leaveDays.sort();
    });
  }

  void _removeLeaveBlock(Doctor doctor, List<DateTime> leaveBlock) {
    setState(() {
      doctor.leaveDays.removeWhere((date) => leaveBlock.contains(date));
    });
  }

  void _retryAssignments(int retries) {
    Roster roster = Roster(
      doctors: doctors,
      shifts: shifts,
      hoursPerShiftType: hoursPerShiftType,
      maxOvertimeHours: maxOvertimeHours,
      postCallBeforeLeave: _postCallBeforeLeaveValueNotifier.value,
    );
    roster.retryAssignments(retries);
    setState(() {
      doctors = roster.doctors;
      shifts = roster.shifts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors Overtime Call Roster'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _retryAssignments(1000);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: RosterDisplay(
              shifts: shifts,
              isPublicHoliday: _isPublicHoliday,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: DoctorsSummaryTable(doctors: doctors),
                ),
                Expanded(
                  flex: 1,
                  child: LeaveManagement(
                    doctors: doctors,
                    onAddLeave: _addLeaveDays,
                    onRemoveLeave: _removeLeaveBlock,
                    postCallBeforeLeaveValueNotifier:
                        _postCallBeforeLeaveValueNotifier,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigate to a page to add doctors or leave days
        },
      ),
    );
  }
}
