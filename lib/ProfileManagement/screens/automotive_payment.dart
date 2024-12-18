import 'package:autocare_automotiveshops/Navigation%20Bar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/commission_services.dart';

class AutomotivePayment extends StatefulWidget {
  final String serviceProviderUid;
  final double commissionLimit;
  final Map<String, double>? totalCommission;

  const AutomotivePayment({
    super.key,
    required this.serviceProviderUid,
    required this.commissionLimit,
    required this.totalCommission,
  });

  @override
  State<AutomotivePayment> createState() => _AutomotivePaymentState();
}

class _AutomotivePaymentState extends State<AutomotivePayment> {
  final Logger logger = Logger();
  bool isLoading = false;

  // Function to update status and navigate
  Future<void> updateStatus(String serviceProviderUid) async {
    setState(() => isLoading = true);
    try {
      await CommissionService.updateStatus(serviceProviderUid, 'Verified');
      await CommissionService.updateLimit(
          serviceProviderUid, widget.commissionLimit,
          widget.totalCommission
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully Paid'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      logger.i('Status and limit updated for $serviceProviderUid');

      // Navigate to the Navbar screen after completion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navbar()),
      );
    } catch (e) {
      logger.e('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update status.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text(
          'Payment Gateway',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Confirm Payment",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "You are about to pay for AutoCare's commission with the amount of ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: "₱${(100 + (widget.totalCommission![widget.serviceProviderUid]! - widget.commissionLimit)).toString()}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Limit will be set to ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: "₱${(((widget.totalCommission![widget.serviceProviderUid]! - widget.commissionLimit) + widget.commissionLimit) + 100).toString()}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const TextSpan(
                                  text: ".",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          )

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      final bool confirm =
                          await showConfirmationDialog(context);
                      if (confirm) {
                        await updateStatus(widget.serviceProviderUid);
                      }
                    },
                    icon: const Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

// Confirmation Dialog
  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Confirm Payment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: const Text(
              "Thank you for your payment. Your services will now be visible to your customers.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
