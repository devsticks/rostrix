import 'package:flutter/material.dart';
import '../models/doctor.dart';

class LeaveDaysInput extends StatefulWidget {
  final Doctor doctor;

  const LeaveDaysInput({super.key, required this.doctor});

  @override
  LeaveDaysInputState createState() => LeaveDaysInputState();
}

class LeaveDaysInputState extends State<LeaveDaysInput> {
  List<DateTime> leaveDays = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Leave Days for ${widget.doctor.name}'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _selectDate,
            child: const Text('Select Leave Days'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: leaveDays.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${leaveDays[index].toLocal()}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, leaveDays);
            },
            child: const Text('Save Leave Days'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null && !leaveDays.contains(picked)) {
      setState(() {
        leaveDays.add(picked);
      });
    }
  }
}
