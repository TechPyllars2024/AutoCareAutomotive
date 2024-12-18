import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/automotive_shop_profile_model.dart';
import '../models/feedbacks_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  // Fetch profile data from Firestore
  Future<AutomotiveProfileModel?> fetchProfileData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Attempt to get the document from Firestore
      final doc = await _firestore
          .collection('automotiveShops_profile')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        // Casting 'remainingSlots' to the expected nested map type
        final remainingSlots =
            (data['remainingSlots'] as Map<String, dynamic>?)?.map(
                  (key, value) => MapEntry(
                    key,
                    (value as Map<String, dynamic>).map(
                      (innerKey, innerValue) =>
                          MapEntry(innerKey, innerValue as int),
                    ),
                  ),
                ) ??
                <String, Map<String, int>>{};

        return AutomotiveProfileModel(
          uid: user.uid,
          serviceProviderUid: data['serviceProviderUid'] ?? user.uid,
          shopName: data['shopName'] ?? '',
          location: data['location'] ?? '',
          coverImage: data['coverImage'] ?? '',
          profileImage: data['profileImage'] ?? '',
          daysOfTheWeek: (data['daysOfTheWeek'] ?? []).cast<String>(),
          operationTime: data['operationTime'] ?? '',
          serviceSpecialization:
              (data['serviceSpecialization'] ?? []).cast<String>(),
          verificationStatus: data['verificationStatus'] ?? '',
          totalRatings: (data['totalRatings'] as num?)?.toDouble() ?? 0.0,
          numberOfRatings: data['numberOfRatings'] ?? 0,
          numberOfBookingsPerHour: data['numberOfBookingsPerHour'] ?? 0,
          remainingSlots: remainingSlots,
          commissionLimit: data['commissionLimit'] ?? 0.0,
        );
      } else {
        // Return a default profile model if no data is found
        return AutomotiveProfileModel(
          uid: user.uid,
          serviceProviderUid: user.uid,
          shopName: '',
          location: '',
          coverImage: '',
          profileImage: '',
          daysOfTheWeek: [],
          operationTime: '',
          serviceSpecialization: [],
          verificationStatus: '',
          totalRatings: 0.0,
          numberOfRatings: 0,
          numberOfBookingsPerHour: 0,
          remainingSlots: <String, Map<String, int>>{},
          commissionLimit: 0.0,
        );
      }
    } catch (e) {
      // Handle potential Firestore errors
      logger.i('Error fetching profile data: $e');
      return null;
    }
  }

  // Save profile data to Firestore
  Future<void> saveUserProfile(AutomotiveProfileModel updatedProfile) async {
    try {
      await _firestore
          .collection('automotiveShops_profile')
          .doc(updatedProfile.uid)
          .set(updatedProfile.toMap());
    } catch (e) {
      // Handle potential Firestore errors
      logger.i('Error saving profile data: $e');
    }
  }

  Stream<List<FeedbackModel>> fetchFeedbacks(String serviceProviderUid) {
    return _firestore
        .collection('feedback')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((e) {
      logger.i(
          'Error fetching feedbacks for provider ID $serviceProviderUid: $e');
    });
  }

  // Fetch service provider by uid
  Future<Map<String, dynamic>> fetchProviderByUid(String uid) async {
    try {
      DocumentSnapshot providerSnapshot = await FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(uid)
          .get();

      Map<String, dynamic> data =
          providerSnapshot.data() as Map<String, dynamic>;

      // Fetch feedbacks for the provider
      QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('serviceProviderUid', isEqualTo: uid)
          .get();

      List<FeedbackModel> feedbacks = feedbackSnapshot.docs
          .map((doc) =>
              FeedbackModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Calculate total ratings and number of ratings
      double totalRatings =
          feedbacks.fold(0, (sum, feedback) => sum + feedback.rating);
      int numberOfRatings = feedbacks.length;

      // Add totalRatings and numberOfRatings to the data map
      data['totalRatings'] = totalRatings;
      data['numberOfRatings'] = numberOfRatings;

      return data;
    } catch (e) {
      logger.i('Error fetching provider by UID $uid: $e');
      return {};
    }
  }
}
