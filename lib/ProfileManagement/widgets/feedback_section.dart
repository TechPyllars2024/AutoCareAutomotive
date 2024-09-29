import 'package:flutter/material.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Feedbacks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PhysicalModel(
            color: Colors.white,
            elevation: 4, // Adds elevation to the container
            borderRadius: BorderRadius.circular(16), // Matches the container's borderRadius
            shadowColor: Colors.grey,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paul Vincent Lerado', style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                      child: Text(
                        'I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                            'However, the service took longer than expected, so providing more accurate time estimates would be helpful.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
