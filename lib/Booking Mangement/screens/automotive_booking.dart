import 'package:flutter/material.dart';
import 'package:autocare_automotiveshops/Booking%20Mangement/widgets/bookingButton.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'DATEDATE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150, // Adjust the height as needed
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0), // Circular edges
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Booking Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '10:30 AM',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8.0), // Add spacing between text and button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BookingButton(
                              text: 'Decline',
                              color: Colors.grey,
                              padding: 10.0,
                              onTap: () {
                                // Handle tap
                                print('declined');
                              },
                            ),
                            BookingButton(
                              text: 'Accept',
                              color: Colors.orange,
                              padding: 10.0,
                              onTap: () {
                                // Handle tap
                                print('accepted');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // The second tab content
            const Center(child: Text('Booking History')),
          ],
        ),
      ),
    );
  }
}
