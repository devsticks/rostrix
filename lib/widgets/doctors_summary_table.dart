import 'package:flutter/material.dart';
import '../models/doctor.dart';

class DoctorsSummaryTable extends StatelessWidget {
  final List<Doctor> doctors;

  const DoctorsSummaryTable({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 10.0, // Adjust the column spacing as needed
        columns: const [
          DataColumn(
              label:
                  Expanded(child: Text('Doctor', textAlign: TextAlign.center))),
          DataColumn(
              label: Expanded(
                  child: Text('Overtime Hours', textAlign: TextAlign.center)),
              numeric: true),
          DataColumn(
              label: Expanded(
                  child: Text('Weekday Overnight Calls',
                      textAlign: TextAlign.center)),
              numeric: true),
          DataColumn(
              label: Expanded(
                  child: Text('2nd On Call Weekday Calls',
                      textAlign: TextAlign.center)),
              numeric: true),
          DataColumn(
              label: Expanded(
                  child: Text('CS Weekday Cover', textAlign: TextAlign.center)),
              numeric: true),
          DataColumn(
              label: Expanded(
                  child: Text('Weekend/PH Calls', textAlign: TextAlign.center)),
              numeric: true),
          DataColumn(
              label: Expanded(
                  child: Text('CS Weekend Cover', textAlign: TextAlign.center)),
              numeric: true),
        ],
        rows: doctors.map((doctor) {
          return DataRow(cells: [
            DataCell(Text(doctor.name)),
            DataCell(Text(doctor.overtimeHours.toStringAsFixed(1))),
            DataCell(Text(doctor.overnightWeekdayCalls.toString())),
            DataCell(Text(doctor.secondOnCallWeekdayCalls.toString())),
            DataCell(Text(doctor.caesarCoverWeekdayCalls.toString())),
            DataCell(Text(doctor.weekendCalls.toString())),
            DataCell(Text(doctor.caesarCoverWeekendCalls.toString())),
          ]);
        }).toList(),
      ),
    );
  }
}
