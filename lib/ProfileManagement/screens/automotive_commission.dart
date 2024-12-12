import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/commission_model.dart';
import '../services/commission_services.dart';

class AutomotiveCommission extends StatefulWidget {
  final serviceProviderUid;

  const AutomotiveCommission({super.key, required this.serviceProviderUid});

  @override
  State<AutomotiveCommission> createState() => _AutomotiveCommissionState();
}

class _AutomotiveCommissionState extends State<AutomotiveCommission> {
  Map<String, double>? totalCommission;
  List<Commission> commissionDetails = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadCommissionData();
    _calculateTotalCommission();
  }

  Future<void> _calculateTotalCommission() async {
    final total = await CommissionService.calculateTotalCommissionByProvider();
    setState(() {
      totalCommission = total;
    });
  }

  Future<void> _loadCommissionData() async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    final commissions = await CommissionService.fetchCommissionDetails(
        widget.serviceProviderUid);

    setState(() {
      commissionDetails = commissions;
      isLoading = false;
    });
  }

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
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ), // Show loading spinner
            )
          : SingleChildScrollView(
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
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  totalCommission != null
                                      ? '₱ ${totalCommission?[widget.serviceProviderUid]}'
                                      : '₱ 0',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            '2% of every booking\ngoes to AutoCare',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Commission Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children:
                          List.generate(commissionDetails.length, (index) {
                        final commission = commissionDetails[index];
                        return Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Car Owner and Service Name (First Column)
                                Text(
                                  commission.carOwnerName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Service Name (Second Column)
                                Text(
                                  commission.serviceName,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 8),

                                // Pricing (Third Column)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${commission.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '+ ₱ ${commission.commissionAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
