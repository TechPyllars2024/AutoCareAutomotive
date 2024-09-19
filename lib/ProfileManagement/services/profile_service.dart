import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/automotive_shop_profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        // If data exists, return a populated AutomotiveProfileModel
        return AutomotiveProfileModel.fromDocument(data, user.uid);
      } else {
        // Return a default profile model if no data is found
        return AutomotiveProfileModel(
          uid: user.uid,
          shopName: 'Shop Name', // Default value
          location: 'Location', // Default value
          coverImage: '', // Default value
          profileImage: '', // Default value
          daysOfTheWeek: [], // Default empty string
          operationTime: '', // Default value
          serviceSpecialization: [], // Default empty list
        );
      }
    } catch (e) {
      // Handle potential Firestore errors
      print('Error fetching profile data: $e');
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
      print('Error saving profile data: $e');
    }
  }
}
