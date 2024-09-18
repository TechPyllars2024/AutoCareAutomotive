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
        body: TabBarView(
          children: [
            // The first tab content
            Center(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Number of columns
                  crossAxisSpacing: 10.0, // Horizontal spacing
                  mainAxisSpacing: 10.0, // Vertical spacing
                ),
                itemCount: 10, // Number of items in the grid
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: Center(
                      child: Text('Item $index'),
                    ),
                  );
                },
              ),
            ),
            // The second tab content
            const Center(child: Text('Booking History')),
          ],
        ),
      ),
    );
  }
}
