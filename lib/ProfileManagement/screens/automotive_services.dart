import 'package:flutter/material.dart';

class AutomotiveServices extends StatefulWidget {
  const AutomotiveServices({super.key});

  @override
  State<AutomotiveServices> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<AutomotiveServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('Services', style: TextStyle(fontWeight: FontWeight.w900),), backgroundColor: Colors.grey.shade300,),
    );
  }
}
