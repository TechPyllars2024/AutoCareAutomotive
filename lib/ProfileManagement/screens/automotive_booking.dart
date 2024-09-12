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
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Bookings', style: TextStyle(fontWeight: FontWeight.w900),), backgroundColor: Colors.grey.shade300,),
    );
  }
}
