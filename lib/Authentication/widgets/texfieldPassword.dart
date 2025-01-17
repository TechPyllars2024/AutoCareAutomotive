import 'package:flutter/material.dart';

class TextFieldPassword extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData? icon;
  final TextInputType textInputType;
  final String? Function(String?)? validator;

  const TextFieldPassword({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    this.icon,
    required this.textInputType,
    this.validator,
  });

  @override
  State<TextFieldPassword> createState() => _TextFieldPasswordState();
}

class _TextFieldPasswordState extends State<TextFieldPassword> {
  bool _isPasswordVisible = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,
            child: TextField(
              style: const TextStyle(fontSize: 15),
              controller: widget.textEditingController,
              obscureText: widget.isPass && !_isPasswordVisible,
              keyboardType: widget.textInputType,
              decoration: InputDecoration(
                labelText: widget.hintText,
                prefixIcon: widget.icon != null
                    ? Icon(widget.icon, color: Colors.grey.shade800, size: 18)
                    : null,
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 77, 76, 76)),
                suffixIcon: widget.isPass
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey.shade800,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.orange.shade900),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  errorMessage = widget.validator?.call(value);
                });
              },
            ),
          ),
          if (errorMessage != null && errorMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
