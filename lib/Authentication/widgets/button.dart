import 'package:flutter/material.dart';

class MyButtons extends StatelessWidget {
  final VoidCallback? onTap; // Allow for null callbacks
  final String text;
  final bool isLoading; // Add this parameter

  const MyButtons({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false, // Default to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: isLoading ? null : onTap, // Disable tap when loading
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,

          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),

            ),

            color: Colors.orange.shade900, // Keep the button color consistent
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Display text or loading indicator based on isLoading
              if (isLoading)
                const CircularProgressIndicator(
                  color: Colors.white,

                )
              else
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
