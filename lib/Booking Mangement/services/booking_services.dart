import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  Future<List<BookingModel>> fetchBookingRequests(String serviceProviderUid) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('bookings')
          .where('serviceProviderUid', isEqualTo: serviceProviderUid)
          .get();

      List<BookingModel> bookings = snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>)
          ..bookingId = doc.id; // Set the bookingId from Firestore document ID
      }).toList();

      logger.i('Fetched ${bookings.length} booking requests for provider: $serviceProviderUid');
      return bookings;
    } catch (e) {
      logger.e('Failed to fetch booking requests: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }
}
