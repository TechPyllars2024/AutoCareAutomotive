import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for state management

class DaysOfTheWeekController extends GetxController {
  var selectedOptionList = <String>[].obs;
  var selectedOption = ''.obs;

  // Update selected option based on conditions
  void updateSelectedOption() {
    Set<String> selectedDays = selectedOptionList.toSet(); // Convert list to set

    if (selectedDays.length == 7) {
      selectedOption.value = 'Everyday';
    } else if (selectedDays.containsAll([
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ]) &&
        !selectedDays.contains('Saturday') &&
        !selectedDays.contains('Sunday')) {
      selectedOption.value = 'Weekday';
    } else {
      selectedOption.value = selectedOptionList.join(', ');
    }
  }
}

class DayOfTheWeek extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final void Function(List<String>)? onSelectionChanged;
  final DaysOfTheWeekController controller;

  const DayOfTheWeek({
    super.key,
    required this.options,
    required this.hintText,
    required this.controller,
    this.onSelectionChanged,
  });

  @override
  State<DayOfTheWeek> createState() => _DayOfTheWeekState();
}

class _DayOfTheWeekState extends State<DayOfTheWeek> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showMultiSelectDialog(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: Obx(() => widget.controller.selectedOptionList.isEmpty
                    ? Text(
                  widget.hintText,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )
                    : Text(
                  widget.controller.selectedOption.value,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Options'),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.options.map((option) {
                return Obx(() => CheckboxListTile(
                  title: Text(option),
                  value: widget.controller.selectedOptionList.contains(option),
                  onChanged: (bool? value) {
                    if (value == true) {
                      widget.controller.selectedOptionList.add(option);
                    } else {
                      widget.controller.selectedOptionList.remove(option);
                    }
                    widget.controller.updateSelectedOption(); // Update selected options
                    if (widget.onSelectionChanged != null) {
                      widget.onSelectionChanged!(widget.controller.selectedOptionList);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ));
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
