import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../Authentication/Widgets/snackBar.dart';
import '../../Booking Mangement/models/booking_model.dart';
import '../models/commission_model.dart';

class CommissionService {
  final Logger logger = Logger();
  static const double commissionRate = 0.02; // Commission rate (2%)

  static Future<void> saveCommissionDetails(BookingModel booking) async {
    try {
      final double commissionAmount =
      Commission.calculateCommission(booking.totalPrice, commissionRate);

      final commissionId = FirebaseFirestore.instance
          .collection('commissions').doc().id;

      // Create a Commission object
      final commission = Commission(
        commissionId: commissionId,
        bookingId: booking.bookingId!,
        carOwnerName: booking.fullName,
        serviceName: booking.selectedService.join(', '),
        totalPrice: booking.totalPrice,
        commissionAmount: commissionAmount,
      );

      await FirebaseFirestore.instance
          .collection('commissions')
          .doc(commissionId)
          .set(commission.toMap());
    } catch (error) {
      Utils.showSnackBar('Failed to save commission details.');
    }
  }

  static Future<List<Commission>> fetchCommissionDetails() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('commissions')
          .get();

      List<Commission> commissionDetails = [];
      for (var doc in querySnapshot.docs) {
        final commission = Commission.fromMap(doc.data());
        commissionDetails.add(commission);
      }
      return commissionDetails;
    } catch (error) {
      print('Error fetching commission data: $error');
      return [];
    }
  }

  static Future<double> calculateTotalCommission() async {
    double total = 0.0;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('commissions')
          .get();

      // Loop through the documents and sum the commission amounts
      for (var doc in querySnapshot.docs) {
        final commission = Commission.fromMap(doc.data());
        total += commission.commissionAmount;
      }
    } catch (error) {
      print('Error fetching commission data: $error');
    }
    return total;
  }
}
