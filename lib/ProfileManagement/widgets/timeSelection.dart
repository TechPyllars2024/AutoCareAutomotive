import 'package:flutter/material.dart';

class TimePickerDisplay extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay)? onTimeSelected;

  const TimePickerDisplay({
    Key? key,
    required this.initialTime,
    this.onTimeSelected,
  }) : super(key: key);

  @override
  _TimePickerDisplayState createState() => _TimePickerDisplayState();
}

class _TimePickerDisplayState extends State<TimePickerDisplay> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      if (widget.onTimeSelected != null) {
        widget.onTimeSelected!(_selectedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Text(_selectedTime.format(context)),
    );
  }
}
