import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String hintText;
  final bool isGoogleLoading;
  final double width;

  const GoogleButton({
    super.key,
    required this.onTap,
    required this.hintText,
    this.isGoogleLoading = false,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGoogleLoading ? null : onTap,
      child: Container(
        width: width,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogleLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
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
