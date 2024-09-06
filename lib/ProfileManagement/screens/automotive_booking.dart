import 'package:flutter/material.dart';

class AutomotiveBooking extends StatefulWidget {
  const AutomotiveBooking({super.key});

  @override
  State<AutomotiveBooking> createState() => _AutomotiveBookingState();
}

class _AutomotiveBookingState extends State<AutomotiveBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings'),),
    );
  }
}
