import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/doctor.dart';

class LeaveManagement extends StatefulWidget {
  final List<Doctor> doctors;
  final Function(Doctor, List<DateTime>) onAddLeave;
  final Function(Doctor, List<DateTime>) onRemoveLeave;
  final ValueNotifier<bool> postCallBeforeLeaveValueNotifier;

  const LeaveManagement({
    Key? key,
    required this.doctors,
    required this.onAddLeave,
    required this.onRemoveLeave,
    required this.postCallBeforeLeaveValueNotifier,
  }) : super(key: key);

  @override
  _LeaveManagementState createState() => _LeaveManagementState();
}

class _LeaveManagementState extends State<LeaveManagement> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  Doctor? _selectedDoctor;
  late bool _postCallBeforeLeave;

  @override
  void initState() {
    super.initState();
    _postCallBeforeLeave = widget.postCallBeforeLeaveValueNotifier.value;
  }

  List<Widget> _buildFormElements() {
    return [
      DropdownButton<Doctor>(
        isExpanded: true,
        hint: const Text('Select Doctor'),
        value: _selectedDoctor,
        onChanged: (Doctor? newValue) {
          setState(() {
            _selectedDoctor = newValue;
          });
        },
        items: widget.doctors.map((Doctor doctor) {
          return DropdownMenuItem<Doctor>(
            value: doctor,
            child: Text(doctor.name),
          );
        }).toList(),
      ),
      TextField(
        controller: _startDateController,
        decoration: const InputDecoration(labelText: 'Start Date (yyyy-mm-dd)'),
      ),
      TextField(
        controller: _endDateController,
        decoration: const InputDecoration(labelText: 'End Date (yyyy-mm-dd)'),
      ),
      ElevatedButton(
        onPressed: () {
          if (_selectedDoctor != null &&
              _startDateController.text.isNotEmpty &&
              _endDateController.text.isNotEmpty) {
            DateTime startDate = DateTime.parse(_startDateController.text);
            DateTime endDate = DateTime.parse(_endDateController.text);
            List<DateTime> leaveDays = [];
            for (DateTime date = startDate;
                date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
                date = date.add(const Duration(days: 1))) {
              leaveDays.add(date);
            }
            widget.onAddLeave(_selectedDoctor!, leaveDays);
            setState(() {
              // Clear the selection and input fields
              _selectedDoctor = null;
              _startDateController.clear();
              _endDateController.clear();
            });
          }
        },
        child: const Text('Add Leave'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
                value: _postCallBeforeLeave,
                onChanged: (value) {
                  setState(() {
                    _postCallBeforeLeave = value!;
                    widget.postCallBeforeLeaveValueNotifier.value = value;
                  });
                }),
            Expanded(child: Text('Post-call the day before leave')),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            var formElements = _buildFormElements();
            if (constraints.maxWidth < 400) {
              return Column(children: formElements);
            } else {
              return Row(
                children: formElements
                    .map((widget) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: widget,
                          ),
                        ))
                    .toList(),
              );
            }
          },
        ),
        ListView(
          shrinkWrap: true, // Allows ListView to take minimum needed space
          physics:
              NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
          children: widget.doctors.expand((doctor) {
            List<List<DateTime>> leaveBlocks =
                _getLeaveBlocks(doctor.leaveDays);
            return leaveBlocks.map((block) {
              DateTime startDate = block.first;
              DateTime endDate = block.last;
              return ListTile(
                title: Text(
                    '${doctor.name}: ${startDate.toIso8601String().split('T')[0]} - ${endDate.toIso8601String().split('T')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget.onRemoveLeave(doctor, block);
                  },
                ),
              );
            }).toList();
          }).toList(),
        ),
      ],
    );
  }

  List<List<DateTime>> _getLeaveBlocks(List<DateTime> leaveDays) {
    List<DateTime> modifiableLeaveDays =
        List.from(leaveDays); // Create a modifiable copy
    modifiableLeaveDays.sort();

    List<List<DateTime>> leaveBlocks = [];
    List<DateTime> currentBlock = [];

    for (DateTime date in modifiableLeaveDays) {
      if (currentBlock.isEmpty) {
        currentBlock.add(date);
      } else {
        if (date.difference(currentBlock.last).inDays == 1) {
          currentBlock.add(date);
        } else {
          leaveBlocks.add(List.from(currentBlock));
          currentBlock.clear();
          currentBlock.add(date);
        }
      }
    }

    if (currentBlock.isNotEmpty) {
      leaveBlocks.add(currentBlock);
    }

    return leaveBlocks;
  }
}
