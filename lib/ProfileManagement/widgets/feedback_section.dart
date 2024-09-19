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
          child: Text('Feedbacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paul Vincent Lerado', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Text('I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                      'However, the service took longer than expected, so providing more accurate time estimates would be helpful.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
