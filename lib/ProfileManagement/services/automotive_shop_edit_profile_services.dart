import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../models/automotive_shop_profile_model.dart';

class AutomotiveShopEditProfileServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final Logger logger = Logger();

  Future<File?> pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> uploadImage(File image, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<AutomotiveProfileModel?> fetchProfileData(String uid) async {
    final doc =
        await _firestore.collection('automotiveShops_profile').doc(uid).get();
    if (doc.exists) {
      return AutomotiveProfileModel.fromDocument(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> saveProfile(
      {required String uid,
      required String serviceProviderUid,
      required String shopName,
      required String location,
      required File? coverImage,
      required File? profileImage,
      required List<String> daysOfTheWeek,
      required String operationTime,
      required List<String> serviceSpecialization,
      required String verificationStatus,
      required double totalRatings,
      required int numberOfRatings,
      required int numberOfBookingsPerHour,
      required Map<String, Map<String, int>> remainingSlots,
      required double commissionLimit
      }) async {
    final Map<String, dynamic> updatedData = {};

    if (coverImage != null) {
      updatedData['coverImage'] =
          await uploadImage(coverImage, 'automotiveCoverImages/$uid.jpg');
    }

    if (profileImage != null) {
      updatedData['profileImage'] =
          await uploadImage(profileImage, 'automotiveProfileImages/$uid.jpg');
    }

    updatedData['serviceProviderUid'] = serviceProviderUid;
    updatedData['shopName'] = shopName;
    updatedData['location'] = location;
    updatedData['daysOfTheWeek'] = daysOfTheWeek;
    updatedData['operationTime'] = operationTime;
    updatedData['serviceSpecialization'] = serviceSpecialization;
    updatedData['verificationStatus'] = verificationStatus;
    updatedData['totalRatings'] = totalRatings;
    updatedData['numberOfRatings'] = numberOfRatings;
    updatedData['numberOfBookingsPerHour'] = numberOfBookingsPerHour;
    updatedData['commissionLimit'] = commissionLimit;
    updatedData['remainingSlots'] = remainingSlots.map((date, slots) {
      // Find the highest remaining slot value for the day
      int highestRemaining = slots.values.reduce((a, b) => a > b ? a : b);
      return MapEntry(
        date,
        slots.map((time, remaining) {
          // Calculate the adjustment based on the highest remaining value
          int difference = highestRemaining - remaining;
          // Subtract the adjustment from the new number of bookings per hour
          int adjustedRemaining = numberOfBookingsPerHour - difference;
          // Ensure adjusted remaining slots are non-negative
          adjustedRemaining = adjustedRemaining >= 0 ? adjustedRemaining : 0;
          logger.i(
            "Date: $date, Time: $time, Difference: $difference, Adjusted remaining slots: $adjustedRemaining",
          );
          return MapEntry(time, adjustedRemaining);
        }),
      );
    });

    // Save the adjusted data
    final docRef = _firestore.collection('automotiveShops_profile').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update(updatedData);
    } else {
      await docRef.set(updatedData);
    }
  }
}
