import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoCare Automotive Shops',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('AutoCare Automotive Shops'),
        ),
        body: Center(
          child: Text('Welcome to AutoCare Automotive Shops!'),
        ),
      ),
    );
  }
}
