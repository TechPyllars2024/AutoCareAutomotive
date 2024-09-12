import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for state management

// Controller for managing selected days
class DaysOfTheWeekController extends GetxController {
  var selectedOptionList = <String>[].obs;
  var selectedOption = ''.obs;

  // Update selected option based on selected days
  void updateSelectedOption() {
    final selectedDays = selectedOptionList.toSet(); // Convert list to set

    if (selectedDays.length == 7) {
      selectedOption.value = 'Everyday';
    } else if (selectedDays.containsAll([
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
    ]) &&
        !selectedDays.contains('Saturday') &&
        !selectedDays.contains('Sunday')) {
      selectedOption.value = 'Weekdays';
    } else {
      selectedOption.value = selectedOptionList.join(', ');
    }
  }
}

// Widget for selecting days of the week
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
            onTap: _showMultiSelectDialog,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[100], // Light grey background
                ),
                child: Obx(
                      () => Text(
                    widget.controller.selectedOptionList.isEmpty
                        ? widget.hintText
                        : widget.controller.selectedOption.value,
                    style: TextStyle(
                      color: widget.controller.selectedOptionList.isEmpty
                          ? Colors.grey[700]
                          : Colors.grey[900],
                      fontSize: 16,
                    ),
                  ),
                ),
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
          title: Text(
            'Select Options',
            style: TextStyle(color: Colors.grey[800]), // Dark grey text
          ),
          backgroundColor: Colors.grey[200], // Very light grey background
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.options.map((option) {
                return Obx(
                      () => CheckboxListTile(
                    title: Text(
                      option,
                      style: TextStyle(color: Colors.grey[800]), // Dark grey text
                    ),
                    value: widget.controller.selectedOptionList.contains(option),
                    onChanged: (bool? value) {
                      if (value == true) {
                        widget.controller.selectedOptionList.add(option);
                      } else {
                        widget.controller.selectedOptionList.remove(option);
                      }
                      widget.controller.updateSelectedOption(); // Update selected options
                      widget.onSelectionChanged?.call(widget.controller.selectedOptionList);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.grey[600], // Color for the checkbox when selected
                    checkColor: Colors.white, // Color for the check mark
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.grey[800]), // Dark grey text
              ),
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
