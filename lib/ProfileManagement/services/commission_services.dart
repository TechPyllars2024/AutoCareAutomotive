import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../Authentication/Widgets/snackBar.dart';
import '../../Booking Mangement/models/booking_model.dart';
import '../models/automotive_shop_profile_model.dart';
import '../models/commission_model.dart';

class CommissionService {
  final logger = Logger();
  static const double commissionRate = 0.02;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> saveCommissionDetails(BookingModel booking) async {
    try {
      final double commissionAmount =
          Commission.calculateCommission(booking.totalPrice, commissionRate);

      final commissionId =
          FirebaseFirestore.instance.collection('commissions').doc().id;

      // Create a Commission object
      final commission = Commission(
          commissionId: commissionId,
          bookingId: booking.bookingId!,
          carOwnerName: booking.fullName,
          serviceName: booking.selectedService.join(', '),
          totalPrice: booking.totalPrice,
          commissionAmount: commissionAmount,
          serviceProviderUid: booking.serviceProviderUid);

      await FirebaseFirestore.instance
          .collection('commissions')
          .doc(commissionId)
          .set(commission.toMap());
    } catch (error) {
      Utils.showSnackBar('Failed to save commission details.');
    }
  }

  static Future<List<Commission>> fetchCommissionDetails(
      String serviceProviderUid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('commissions')
          .where('serviceProviderUid', isEqualTo: serviceProviderUid)
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

  static Future<Map<String, double>>
      calculateTotalCommissionByProvider() async {
    Map<String, double> totalCommissions = {};
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('commissions').get();

      // Loop through the documents and sum the commission amounts by serviceProviderUid
      for (var doc in querySnapshot.docs) {
        final commission = Commission.fromMap(doc.data());
        if (totalCommissions.containsKey(commission.serviceProviderUid)) {
          totalCommissions[commission.serviceProviderUid] =
              totalCommissions[commission.serviceProviderUid]! +
                  commission.commissionAmount;
        } else {
          totalCommissions[commission.serviceProviderUid] =
              commission.commissionAmount;
        }
      }
    } catch (error) {
      print('Error fetching commission data: $error');
    }
    return totalCommissions;
  }

  static Future<double> calculateTotalEarningsByProvider(String serviceProviderUid) async {
    double totalEarnings = 0.0;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('commissions')
          .where('serviceProviderUid', isEqualTo: serviceProviderUid)
          .get();

      for (var doc in querySnapshot.docs) {
        final commission = Commission.fromMap(doc.data());
        totalEarnings += commission.totalPrice;
      }
    } catch (error) {
      print('Error calculating total earnings: $error');
    }

    return totalEarnings;
  }

  static Future<void> updateStatus(String uid, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(uid)
          .update({
        'verificationStatus': status,
      });
      print('Status successfully updated to $status');
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  static Future<void> updateLimit(String uid, double commissionLimit, Map<String, double>? totalCommission) async {
    try {
      await FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(uid)
          .update({
        'commissionLimit': (((totalCommission![uid]! - commissionLimit) + commissionLimit) + 100),
      });
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  static Future<double?> fetchCommissionLimit(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(uid)
          .get();

      if (doc.exists) {
        // Directly fetch and cast 'commissionLimit' as double
        final data = doc.data();
        if (data != null && data['commissionLimit'] != null) {
          return data['commissionLimit'] as double?;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching commission limit: $e');
      return null;
    }
  }



  static Future<void> updateCommissionTotal(String serviceProviderUid) async {
    try {
      // Reference to the 'commissions' collection for the specific service provider
      var commissionCollection = FirebaseFirestore.instance
          .collection('commissions')
          .where('serviceProviderUid', isEqualTo: serviceProviderUid);

      // Update commissionAmount to 0.00 for all documents matching the criteria
      await commissionCollection.get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'commissionAmount': 0.00});
        }
      });

      print('Commission amounts successfully updated to 0.');
    } catch (e) {
      print('Error updating commission amounts: $e');
    }
  }


}
