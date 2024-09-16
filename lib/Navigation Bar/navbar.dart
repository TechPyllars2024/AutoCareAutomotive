import 'package:autocare_automotiveshops/Booking%20Mangement/screens/automotive_booking.dart';
import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_edit_profile.dart';
import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_profile.dart';
import 'package:autocare_automotiveshops/Service%20Management/screens/manage_services.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
    const ServiceManagementScreen(),
    const AutomotiveProfileScreen(),
    const AutomotiveEditProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey.shade300, // Ensure CurvedNavigationBar background is also transparent

        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(Icons.home, size: 35, color: _page == 0 ? Colors.orange : Colors.black),
          Icon(Icons.calendar_month, size: 35, color: _page == 1 ? Colors.orange : Colors.black),
          Icon(Icons.directions_car, size: 35, color: _page == 2 ? Colors.orange : Colors.black),
          Icon(Icons.person, size: 35, color: _page == 3 ? Colors.orange : Colors.black),
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
