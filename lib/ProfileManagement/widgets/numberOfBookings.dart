import 'package:flutter/material.dart';

class NumberInputController extends StatefulWidget {
  final int initialValue;
  final int min;
  final int max;
  final Function(int) onValueChanged;

  const NumberInputController({
    super.key,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onValueChanged,
  });

  @override
  State<NumberInputController> createState() => _NumberInputControllerState();
}

class _NumberInputControllerState extends State<NumberInputController> {
  late TextEditingController _controller;
  bool _hasError = false; // Flag to track if there's an error

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  void _onChanged(String value) {
    int? newValue = int.tryParse(value);

    // Check if the input is valid and within range
    if (newValue != null && newValue >= widget.min && newValue <= widget.max) {
      setState(() {
        _hasError = false; // Clear error state
      });
      widget.onValueChanged(newValue); // Call the callback with new value
    } else {
      setState(() {
        _hasError = true; // Set error state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _hasError ? Colors.red : Colors.black, // Set border color based on error state
            ),
          ),
          errorText: _hasError ? 'Value exceeds maximum of ${widget.max}' : null, // Show error message
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
