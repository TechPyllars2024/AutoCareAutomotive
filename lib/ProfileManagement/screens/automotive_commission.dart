import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AutomotiveCommission extends StatefulWidget {
  const AutomotiveCommission({super.key});

  @override
  State<AutomotiveCommission> createState() => _AutomotiveCommissionState();
}

class _AutomotiveCommissionState extends State<AutomotiveCommission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text(
          'Commission',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white, // Change the back arrow color here
          onPressed: () {
            Navigator.pop(context); // Go back on press
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade900,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 30,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            '90.0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      '2% of every booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                "Commission Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 10,
                    child: ListTile(
                      title: Text(
                        'Booking 1',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        'Total commission',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: Text(
                        'P 0.00',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
