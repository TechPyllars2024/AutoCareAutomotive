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
      appBar: AppBar(title: Text('Profile'),),
    );
  }
}
