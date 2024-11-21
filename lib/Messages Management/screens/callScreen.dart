import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Caller Info
            Column(
              children: [
                const SizedBox(height: 150),
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Replace with caller image
                ),
                const SizedBox(height: 20),
                const Text(
                  'John Doe', // Caller Name
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Incoming...', // Call duration
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Accept Call Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Handle accept call
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Decline Call Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Handle decline call
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}