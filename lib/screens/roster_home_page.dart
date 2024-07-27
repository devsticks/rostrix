import 'package:flutter/material.dart';
import 'package:rostrem/widgets/loading_overlay.dart';
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
  bool _isLoading = false;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _postCallBeforeLeaveValueNotifier =
      ValueNotifier<bool>(true);
  OverlayEntry? _overlayEntry;
  List<Doctor> doctors = [];
  List<Shift> shifts = [];
  late Roster roster;
  Map<String, double> hoursPerShiftType = {
    'Overnight Weekday': 16,
    'Second On Call Weekday': 6,
    'Caesar Cover Weekday': 3,
    'Overnight Weekend': 12,
    'Day Weekend': 12,
    'Caesar Cover Weekend': 3.6,
  };
  double maxOvertimeHours = 90;
  // year and month for next month
  int year = DateTime.now().add(const Duration(days: 31)).year;
  int month = DateTime.now().add(const Duration(days: 31)).month;

  final List<String> _loadingMessages = [
    'Preparing your new roster...',
    'Crunching the numbers...',
    'Finding the best schedule...',
    'Almost there...',
    'Consulting the interns...',
    'It\'ll be over before the morning...',
    'Continuing management...',
    'Prescribing the perfect shift...',
    'Just a few more stitches...',
    'Making rounds on the schedule...',
    'Analyzing lab results for the best fit...',
    'Diagnosing scheduling conflicts...',
    'Taking a break for a coffee refill...',
    'Preparing the night shift...',
    'Titrating time off...',
    'Treating the roster with care...',
    'Checking the vitals of your schedule...',
    'Administering the final adjustments...',
    'Balancing leave requests...',
    'Operating on the shifts...',
    'Getting it onto the table...',
    'Scrubbing in for the final checks...',
    'Coordinating with the surgical team...',
    'Charting the best course for your team...',
    'Scheduling a healthy work-life balance...',
    'Paging Dr. Schedule...',
    'Adjusting the dosage of hours...',
    'Finding the pulse of the perfect schedule...',
    'Monitoring shift requests...',
    'Consulting the duty roster...',
    'Preparing for shift change...',
    'A healthy dose of shifts coming up...',
    'Fine-tuning the treatment plan...',
    'Putting POP on the changes...',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDoctors();
    _initializeShifts();
    _initializeRoster();
  }

  @override
  void dispose() {
    _postCallBeforeLeaveValueNotifier.dispose();
    super.dispose();
  }

  void _initializeDoctors() {
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

  void _initializeRoster() {
    roster = Roster(
      doctors: doctors,
      shifts: shifts,
      hoursPerShiftType: hoursPerShiftType,
      maxOvertimeHours: maxOvertimeHours,
      postCallBeforeLeave: _postCallBeforeLeaveValueNotifier.value,
    );
    roster.assignShifts();
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

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: LoadingOverlay(
          progressNotifier: _progressNotifier,
          messages: _loadingMessages,
        ),
      ),
    );
  }

  Future<void> _retryAssignments(int retries) async {
    setState(() {
      _isLoading = true;
    });

    _progressNotifier.value = 0.0;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
    await roster.retryAssignments(retries, _progressNotifier);

    setState(() {
      doctors = roster.doctors;
      shifts = roster.shifts;
      _isLoading = false;
    });

    _overlayEntry?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors\' Overtime Call Roster'),
        actions: [
          // Input for the year and month
          Row(
            children: [
              const Text('Year: '),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: TextEditingController(text: year.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    year = int.tryParse(value) ?? year;
                    _initializeShifts();
                  },
                ),
              ),
              const Text('Month: '),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: TextEditingController(text: month.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    month = int.tryParse(value) ?? month;
                    _initializeShifts();
                  },
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _retryAssignments(1000);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.download),
        onPressed: () {
          roster.downloadAsCsv(context);
        },
      ),
    );
  }
}
