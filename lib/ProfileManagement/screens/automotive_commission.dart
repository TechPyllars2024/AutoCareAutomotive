import 'package:autocare_automotiveshops/ProfileManagement/screens/automotive_payment.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/commission_model.dart';
import '../services/commission_services.dart';
import '../services/get_verified_services.dart';
import '../widgets/status_bar.dart';

class AutomotiveCommission extends StatefulWidget {
  final String serviceProviderUid;

  const AutomotiveCommission({super.key, required this.serviceProviderUid});

  @override
  State<AutomotiveCommission> createState() => _AutomotiveCommissionState();
}

class _AutomotiveCommissionState extends State<AutomotiveCommission> {
  Map<String, double>? totalCommission;
  List<Commission> commissionDetails = [];
  late double totalEarnings = 0.0;
  late double commissionLimit = 0.0;
  bool isLoading = true;
  final Logger logger = Logger();
  bool _isVerified = false;
  final GetVerifiedServices _getVerifiedServices = GetVerifiedServices();
  bool _isVerificationStatusLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _loadCommissionData(),
        _calculateTotalCommission(),
        _calculateTotalEarnings(),
        _loadCommissionLimit(),
      ]);
      _checkUserVerificationStatus();
      checkAndUpdateStatus(context, widget.serviceProviderUid, totalCommission);
    } catch (e) {
      logger.e('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkUserVerificationStatus() async {
    String? status = await _getVerifiedServices.fetchStatus(widget.serviceProviderUid);
    setState(() {
      _isVerified = status == 'OnHold';
      _isVerificationStatusLoading = true;
    });
    }

  Future<void> _loadCommissionData() async {
    final commissions = await CommissionService.fetchCommissionDetails(
      widget.serviceProviderUid,
    );
    commissionDetails = commissions;
  }

  Future<void> _calculateTotalCommission() async {
    final total = await CommissionService.calculateTotalCommissionByProvider();
    totalCommission = total;
  }

  Future<void> _calculateTotalEarnings() async {
    final total = await CommissionService.calculateTotalEarningsByProvider(
      widget.serviceProviderUid,
    );
    totalEarnings = total;
  }

  Future<void> _loadCommissionLimit() async {
    final limit = await CommissionService.fetchCommissionLimit(
      widget.serviceProviderUid,
    );
    if (limit != null) {
      commissionLimit = limit;
    }
  }

  Future<void> checkAndUpdateStatus(
    BuildContext context,
    String serviceProviderUid,
    Map<String, double>? totalCommission,
  ) async {
    final commissionValue =
        totalCommission?[serviceProviderUid]?.toDouble() ?? 0.0;

    logger.i('Commission Value: $commissionValue');

    if (commissionValue > commissionLimit) {
      await CommissionService.updateStatus(serviceProviderUid, 'OnHold');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Your account has been put on hold due to exceeding the commission limit.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerificationStatusLoading) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text(
          'My Earnings',
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
              ),
            )

          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Earnings Summary
                  _buildEarningsSummary(),

                  const SizedBox(height: 8),
                  // Commission Card
                  _buildCommissionCard(context),
                  if (_isVerified)
                    const ServiceStatusAlertBox(isVerified: false),
                  const SizedBox(height: 8),
                  // Booking Details
                  _buildBookingDetails(),
                ],
              ),
            ),
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      height: 125,
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
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        '₱ ${totalEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const Text(
              'NOTE: 2% of every booking goes to AutoCare',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ],
        )
      ),
    );
  }

  Widget _buildCommissionCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AutoCare Commission',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₱ ${totalCommission?[widget.serviceProviderUid]?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (totalCommission?[widget.serviceProviderUid] ?? 0) >
                            commissionLimit
                        ? Colors.red
                        : Colors.white,
                  ),
                ),
                Text(
                  'Limit: ₱ ${commissionLimit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
              onPressed:
                  (totalCommission?[widget.serviceProviderUid] ?? 0) > 0.0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AutomotivePayment(
                                serviceProviderUid: widget.serviceProviderUid,
                                commissionLimit: commissionLimit,
                                totalCommission: totalCommission
                              ),
                            ),
                          );
                        }
                      : null,
              child: Text(
                'Send to AutoCare Wallet',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Column(
            children: List.generate(commissionDetails.length, (index) {
              final commission = commissionDetails[index];
              return Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.orange.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            commission.carOwnerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.build_circle_sharp,
                            size: 20,
                            color: Colors.orange.shade900,
                          ),
                          const SizedBox(
                              width: 4),
                          Text(
                            commission.serviceName.length > 50
                                ? '${commission.serviceName.substring(0, 47)}...'
                                : commission.serviceName,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Pricing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .php_rounded,
                                size: 20,
                                color: Colors.orange
                                    .shade900,
                              ),
                              const SizedBox(
                                  width: 4),
                              Text(
                                commission.totalPrice.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
        ],
      ),
    );
  }
}
