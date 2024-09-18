import 'package:flutter/material.dart';

class AutomotiveBookingScreen extends StatefulWidget {
  const AutomotiveBookingScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveBookingScreen> createState() => _AutomotiveBookingState();
}

class _AutomotiveBookingState extends State<AutomotiveBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: const Text(
            'Bookings',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.grey.shade300,
          bottom: TabBar(
            indicatorColor: Colors.blue, // Customize the tab indicator color
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // The first tab content
            Center(child: Text('Upcoming Bookings')),
            // The second tab content
            Center(child: Text('Booking History')),
          ],
        ),
      ),
    );
  }
}
