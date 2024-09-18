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
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),

        child: TextField(
          style: const TextStyle(fontSize: 20),
          controller: textEditingController,
          decoration: InputDecoration(
            labelText: hintText,

            // prefixIcon: icon != null
            //     ? Icon(icon, color: Colors.black45, size: 24)
            //     : null,
            labelStyle: const TextStyle(color: Color.fromARGB(255, 77, 76, 76)),
            border:  OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder:  OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder:  OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          keyboardType: textInputType,
          obscureText: isPass,
        ),
      ),
    );
  }
}