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
      appBar: AppBar(title: Text('Services'),),
    );
  }
}
