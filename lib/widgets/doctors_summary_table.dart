import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'header_text.dart'; // Import the custom header widget

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
          DataColumn(label: HeaderText(text: 'Doctor', width: 120)),
          DataColumn(label: HeaderText(text: 'Overtime Hours', width: 80)),
          DataColumn(
              label: HeaderText(text: 'Overnight Weekday Calls', width: 80)),
          DataColumn(
              label: HeaderText(text: '2nd On Call Weekday Calls', width: 80)),
          DataColumn(
              label: HeaderText(text: 'Caesar Cover Weekday Calls', width: 80)),
          DataColumn(label: HeaderText(text: 'Weekend/PH Calls', width: 80)),
          DataColumn(
              label: HeaderText(text: 'Caesar Cover Weekend Calls', width: 80)),
        ],
        rows: doctors.map((doctor) {
          return DataRow(cells: [
            DataCell(Text(doctor.name)),
            DataCell(Text(doctor.overtimeHours.toString())),
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
