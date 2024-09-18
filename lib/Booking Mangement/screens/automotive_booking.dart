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
            indicatorColor: Colors.orange, // Customize the tab indicator color
            labelColor: Colors.orange, // Color of the selected tab
            unselectedLabelColor: Colors.black, // Color of the unselected tab
            tabs: const [
              Tab(child: Text('Pending', style: TextStyle(fontSize: 18))),
              Tab(child: Text('History', style: TextStyle(fontSize: 18))),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // The first tab content
            Padding(
              padding: EdgeInsets.all(16.0), // Adjust padding as needed
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft, // Align text to the left
                    child: Text(
                      'May 17, 2025',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Row(
                    
                    children: [Text('data')],
                  ),
                ],
              ),
              
            ),
            // The second tab content
            Center(child: Text('Booking History')),
          ],
        ),
      ),
    );
  }
}
