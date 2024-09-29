import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                  color: Colors.white,
                ),
                child: Obx(
                      () => widget.controller.selectedOptionList.isEmpty
                      ? Text(
                    widget.hintText,
                    style: const TextStyle(fontSize: 16),
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
                        backgroundColor: Colors.orange.shade900,
                        deleteIconColor: Colors.white,
                        onDeleted: () {
                          widget.controller.selectedOptionList.remove(option);
                          widget.controller.selectedOption.value = widget.controller.selectedOptionList.join(', ');
                          widget.onSelectionChanged?.call(widget.controller.selectedOptionList);
                        },
                      );
                    }).toList(),
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
          backgroundColor: Colors.white, // Very light grey background
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
                      widget.controller.selectedOption.value = widget.controller.selectedOptionList.join(', ');
                      widget.onSelectionChanged?.call(widget.controller.selectedOptionList);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.orange.shade900, // Color for the checkbox when selected
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
                style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold), // Dark grey text
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
