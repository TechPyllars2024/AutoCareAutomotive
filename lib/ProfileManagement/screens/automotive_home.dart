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
      appBar: AppBar(title: Text('Home'),),
    );
  }
}
