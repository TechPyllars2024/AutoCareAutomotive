import 'package:flutter/material.dart';

class AutomotiveHome extends StatefulWidget {
  const AutomotiveHome({super.key});

  @override
  State<AutomotiveHome> createState() => _AutomotiveHomeState();
}

class _AutomotiveHomeState extends State<AutomotiveHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Home', style: TextStyle(fontWeight: FontWeight.w900),), backgroundColor: Colors.grey.shade300,),
    );
  }
}
