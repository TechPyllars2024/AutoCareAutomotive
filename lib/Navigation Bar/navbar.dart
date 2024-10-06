import 'package:autocare_automotiveshops/Booking%20Mangement/screens/automotive_booking.dart';
import 'package:autocare_automotiveshops/Messages%20Management/screens/automotive_messages.dart';
import 'package:autocare_automotiveshops/Service%20Management/screens/manage_services.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../ProfileManagement/screens/automotive_main_profile.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key, this.child});

  final Widget? child;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {

  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    const AutomotiveBookingScreen(),
    const AutomotiveMessagesScreen(),
    const ServiceManagementScreen(),
    const AutomotiveMainProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey.shade100,

        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(Icons.calendar_month, size: 25, color: _page == 0 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.message, size: 25, color: _page == 1 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.directions_car, size: 25, color: _page == 2 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.person, size: 25, color: _page == 3 ? Colors.orange.shade900 : Colors.grey.shade700),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        index: _page, // Ensure the selected item is highlighted
      ),
      body: _screens[_page], // Display the selected screen
    );
  }
}
