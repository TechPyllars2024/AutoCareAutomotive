import 'package:flutter/material.dart';

class MyButtons extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isLoading;

  const MyButtons({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,

          decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),

            ),

            color: Colors.orange.shade900,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [

              if (isLoading)
                const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
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