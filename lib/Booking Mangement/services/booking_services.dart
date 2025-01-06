import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;


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

  Future<void> deleteBooking(String bookingId) async {
    try {
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      await bookingRef.delete();
      logger.i('Successfully deleted booking with ID: $bookingId');
    } catch (e) {
      logger.e('Error deleting booking: $e');
      rethrow;
    }
  }

  Future<List<BookingModel>> fetchBookings(String serviceProviderUid) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      logger.i('USERUID: ${currentUser.uid}');

      QuerySnapshot snapshot = await firestore
          .collection('bookings')
          .where('serviceProviderUid', isEqualTo: serviceProviderUid)
          .get();

      List<BookingModel> bookings = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Safely cast
        if (data == null) {
          logger.w('Document data is null for doc ID: ${doc.id}');
          return null;
        }
        return BookingModel.fromMap(data);
      })
          .where((booking) => booking != null)
          .toList()
          .cast<BookingModel>();

      logger.i(
          'Fetched ${bookings.length} booking requests for car owner: ${currentUser.uid}');
      return bookings;
    } catch (e) {
      logger.e('Error fetching bookings: $e');
      rethrow;
    }
  }

}
