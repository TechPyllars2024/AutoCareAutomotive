import 'package:flutter/material.dart';

class TimePickerDisplay extends StatefulWidget {
  final TimeOfDay initialTime;
  final TextStyle textStyle;

  const TimePickerDisplay({
    super.key,
    required this.initialTime,
    this.textStyle = const TextStyle(fontSize: 20),
  });

  @override
  State<TimePickerDisplay> createState() => _TimePickerDisplayState();
}

class _TimePickerDisplayState extends State<TimePickerDisplay> {
  late TimeOfDay _timeOfDay;

  @override
  void initState() {
    super.initState();
    _timeOfDay = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatTime(_timeOfDay),
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final int hour = timeOfDay.hourOfPeriod;
    final String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: _timeOfDay,
      context: context,
    );
    if (pickedTime != null) {
      setState(() {
        _timeOfDay = pickedTime;
      });
    }
  }
}
