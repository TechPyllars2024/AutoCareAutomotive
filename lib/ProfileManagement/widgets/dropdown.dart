import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for state management

class DropdownController extends GetxController {
  var selectedOptionList = <String>[].obs;
  var selectedOption = ''.obs;
}

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final void Function(List<String>)? onSelectionChanged;
  final DropdownController controller;

  const CustomDropdown({
    super.key,
    required this.options,
    required this.hintText,
    required this.controller,
    this.onSelectionChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showMultiSelectDialog(),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Set padding of 10 on all sides
              child: Container(
                width: double.infinity, // Full width of the screen
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100], // Light grey background
                ),
                child: Obx(() => widget.controller.selectedOptionList.isEmpty
                    ? Text(
                  widget.hintText,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )
                    : Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: widget.controller.selectedOptionList.map((option) {
                    return Chip(
                      label: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey[700], // Dark grey background for selected options
                      deleteIconColor: Colors.white, // White delete icon
                      onDeleted: () {
                        widget.controller.selectedOptionList.remove(option);
                        widget.controller.selectedOption.value =
                            widget.controller.selectedOptionList.join(', ');
                        if (widget.onSelectionChanged != null) {
                          widget.onSelectionChanged!(widget.controller.selectedOptionList);
                        }
                      },
                    );
                  }).toList(),
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
                    widget.controller.selectedOption.value =
                        widget.controller.selectedOptionList.join(', ');
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
