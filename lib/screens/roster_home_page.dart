import 'package:flutter/material.dart';
import 'package:rostrem/models/assignment_generator.dart';
import 'package:rostrem/widgets/loading_overlay.dart';
import 'package:sidebarx/sidebarx.dart';
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
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _postCallBeforeLeaveValueNotifier =
      ValueNotifier<bool>(true);
  OverlayEntry? _overlayEntry;
  List<Doctor> doctors = [];
  List<Shift> shifts = [];
  late AssignmentGenerator assigner;
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
  late TextEditingController yearController;
  late TextEditingController monthController;

  bool _isSidebarMinimized = false;
  final _sidebarController =
      SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

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
    yearController = TextEditingController(text: year.toString());
    monthController = TextEditingController(text: month.toString());
    _initializeDoctors();
    _initializeShifts();
    _initializeRoster();
  }

  @override
  void dispose() {
    _postCallBeforeLeaveValueNotifier.dispose();
    yearController.dispose();
    monthController.dispose();
    super.dispose();
  }

  void _initializeDoctors() {
    // Initialize doctors
    doctors = [
      Doctor(
          name: "Zintonga",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Egbe", canPerformCaesars: true, canPerformAnaesthetics: false),
      Doctor(
          name: "Berenisco",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Tafeni",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Ngombane",
          canPerformCaesars: true,
          canPerformAnaesthetics: false),
      Doctor(
          name: "Mtshingila",
          canPerformCaesars: true,
          canPerformAnaesthetics: false),
      Doctor(
          name: "Frazer",
          canPerformCaesars: true,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Nkombisa",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Mlenga",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Stickells",
          canPerformCaesars: false,
          canPerformAnaesthetics: true),
      Doctor(
          name: "Noxaka",
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
    assigner = AssignmentGenerator(
      hoursPerShiftType: hoursPerShiftType,
      maxOvertimeHours: maxOvertimeHours,
      postCallBeforeLeave: _postCallBeforeLeaveValueNotifier.value,
    );
    roster = Roster(
      doctors: doctors,
      shifts: shifts,
      assigner: assigner,
    );
    assigner.assignShifts(roster);
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
    _progressNotifier.value = 0.0;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    await roster.retryAssignments(retries, _progressNotifier);

    setState(() {
      doctors = roster.doctors;
      shifts = roster.shifts;
    });

    _overlayEntry?.remove();
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Doctor Summary'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: DoctorsSummaryTable(doctors: doctors),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearMonthSelector() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!_isSmallScreen(context)) {
          // Adjust threshold as needed
          return Row(
            children: [
              const Text('Year: '),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: yearController,
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
                  controller: monthController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    month = int.tryParse(value) ?? month;
                    _initializeShifts();
                  },
                ),
              ),
            ],
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showYearMonthDialog,
          );
        }
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _sidebarController,
      builder: (context, child) {
        switch (_sidebarController.selectedIndex) {
          case 0:
            return _buildRosterContent();
          case 1:
            return _buildLeaveManagementContent();
          default:
            return const Center(child: Text('Page not found'));
        }
      },
    );
  }

  void _showYearMonthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Month"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Year"),
                onChanged: (value) {
                  year = int.tryParse(value) ?? year;
                  _initializeShifts();
                },
              ),
              TextField(
                controller: monthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Month"),
                onChanged: (value) {
                  month = int.tryParse(value) ?? month;
                  _initializeShifts();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRosterContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Roster',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: RosterDisplay(
              shifts: shifts,
              isPublicHoliday: _isPublicHoliday,
            ),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: _showSummaryDialog,
            child: const Text('Show Doctor Summary'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveManagementContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LeaveManagement(
        doctors: doctors,
        onAddLeave: _addLeaveDays,
        onRemoveLeave: _removeLeaveBlock,
        postCallBeforeLeaveValueNotifier: _postCallBeforeLeaveValueNotifier,
      ),
    );
  }

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = _isSmallScreen(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Doctors\' Overtime Call Roster'),
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
              )
            : null,
        actions: <Widget>[
          _buildYearMonthSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _retryAssignments(10000),
            tooltip: 'Regenerate Assignments',
          ),
        ],
      ),
      drawer: isSmallScreen
          ? Drawer(
              child: CustomSidebar(
                controller: _sidebarController,
                onSelectionChanged: (index) {
                  Navigator.of(context).pop(); // Close the drawer
                },
                isSmallScreen: isSmallScreen,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            CustomSidebar(
              controller: _sidebarController,
              onSelectionChanged: (index) {
                // No need to close anything on larger screens
              },
              isSmallScreen: isSmallScreen,
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.download),
        onPressed: () => roster.downloadAsCsv(context),
        tooltip: 'Download as Spreadsheet (CSV)',
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({
    Key? key,
    required this.controller,
    required this.onSelectionChanged,
    required this.isSmallScreen,
  }) : super(key: key);

  final SidebarXController controller;
  final Function(int) onSelectionChanged;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Schedule the state update after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSmallScreen) controller.setExtended(true);
    });
    return SidebarX(
      showToggleButton: !isSmallScreen,
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onPrimary),
        selectedTextStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onPrimary),
        itemTextPadding: const EdgeInsets.only(left: 16),
        selectedItemTextPadding: const EdgeInsets.only(left: 16),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primaryColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.onPrimary),
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColorDark],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: theme.colorScheme.onPrimary.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: IconThemeData(
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: theme.primaryColor,
        ),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/app_icons/Rostrix Logo 192 alpha.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.calendar_today,
          label: 'Roster',
          onTap: () => onSelectionChanged(0),
        ),
        SidebarXItem(
          icon: Icons.access_time,
          label: 'Leave Management',
          onTap: () => onSelectionChanged(1),
        ),
      ],
    );
  }
}
