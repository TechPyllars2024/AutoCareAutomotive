import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData? icon;
  final TextInputType textInputType;
  final Widget? child;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    this.icon,
    required this.textInputType,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextField(
        style: const TextStyle(fontSize: 15),
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: hintText,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.black, size: 24)
              : null,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 77, 76, 76)),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
      ),
    );
  }
}
