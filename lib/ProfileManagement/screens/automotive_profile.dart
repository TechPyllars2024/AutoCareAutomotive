import 'package:flutter/material.dart';

class AutomotiveProfile extends StatefulWidget {
  const AutomotiveProfile({super.key});

  @override
  State<AutomotiveProfile> createState() => _AutomotiveProfileState();
}

class _AutomotiveProfileState extends State<AutomotiveProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Profile', style: TextStyle(fontWeight: FontWeight.w900),), backgroundColor: Colors.grey.shade300,),
    );
  }
}
