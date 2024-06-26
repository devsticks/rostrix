import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shift.dart';

class RosterDisplay extends StatelessWidget {
  final List<Shift> shifts;
  final bool Function(DateTime) isPublicHoliday;

  const RosterDisplay({
    super.key,
    required this.shifts,
    required this.isPublicHoliday,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 20.0, // Adjust the column spacing as needed
        columns: const [
          DataColumn(
              label:
                  Expanded(child: Text('Date', textAlign: TextAlign.center))),
          DataColumn(
              label: Expanded(
                  child: Text('Day/eve (2nd On Call)',
                      textAlign: TextAlign.center))),
          DataColumn(
              label: Expanded(
                  child: Text('Night (Main)', textAlign: TextAlign.center))),
          DataColumn(
              label: Expanded(
                  child: Text('Caesar Cover', textAlign: TextAlign.center))),
        ],
        rows: shifts.map((shift) {
          final isWeekend = shift.date.weekday == DateTime.saturday ||
              shift.date.weekday == DateTime.sunday;
          final isSpecialDay = isWeekend || isPublicHoliday(shift.date);

          return DataRow(
            cells: [
              DataCell(
                Container(
                  color: isSpecialDay ? Colors.grey[300] : null,
                  child: Text(_formatDate(shift.date)),
                ),
              ),
              DataCell(
                Container(
                  color: isSpecialDay ? Colors.grey[300] : null,
                  child: Text(shift.weekendDayDoctor != null
                      ? '${shift.weekendDayDoctor?.name}, ${shift.secondOnCallDoctor?.name}'
                      : shift.secondOnCallDoctor?.name ?? 'None'),
                ),
              ),
              DataCell(
                Container(
                  color: isSpecialDay ? Colors.grey[300] : null,
                  child: Text(shift.mainDoctor?.name ?? 'None'),
                ),
              ),
              DataCell(
                Container(
                  color: isSpecialDay ? Colors.grey[300] : null,
                  child: Text(shift.caesarCoverDoctor?.name ?? 'None'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE dd MMM yyyy').format(date);
  }
}
