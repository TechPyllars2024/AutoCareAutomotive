import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String hintText;
  final bool isGoogleLoading; // Add this parameter
  final double width; // Add width parameter

  const GoogleButton({
    super.key,
    required this.onTap,
    required this.hintText,
    this.isGoogleLoading = false, // Default to false if not provided
    this.width = 220, // Default width, you can adjust as needed
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGoogleLoading ? null : onTap, // Disable tap when loading
      child: Container(
        width: width, // Set a fixed width for the button
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the contents
          children: [
            if (isGoogleLoading)
              const SizedBox(
                width: 24, // Ensure width is consistent
                height: 24, // Ensure height is consistent
                child: CircularProgressIndicator(
                  color: Colors.black, // Change color as needed
                ),
              )
            else
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('lib/Authentication/assets/images/icons/google.png'),
              ),
            const SizedBox(width: 8),
            if (!isGoogleLoading)
              Text(
                hintText,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
