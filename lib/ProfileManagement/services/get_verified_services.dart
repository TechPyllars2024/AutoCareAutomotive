import 'package:autocare_automotiveshops/ProfileManagement/services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../models/automotive_shop_getVerified_model.dart';
import '../models/automotive_shop_profile_model.dart';

class GetVerifiedServices {
  final ProfileService _profileService = ProfileService();
  // Method to pick and upload file
  Future<String?> pickAndUploadFile() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDF files
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Upload the file to Firebase Storage
      try {
        Reference storageRef = FirebaseStorage.instance.ref().child('getVerified/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        return downloadURL;
      } catch (e) {
        throw Exception('Failed to upload file: $e');
      }
    } else {
      return null; // No file selected
    }
  }

  Future<void> saveVerificationData(String fileUrl) async {
    try {
      // Fetch the profile data
      AutomotiveProfileModel? profile = await _profileService.fetchProfileData();

      if (profile != null) {
        final verificationData = VerificationModel(
          uid: profile.uid,
          shopName: profile.shopName,
          location: profile.location,
          dateSubmitted: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          timeSubmitted: DateFormat('HH:mm').format(DateTime.now()),
          fileUrl: fileUrl,
          status: 'pending',
        );

        await FirebaseFirestore.instance
            .collection('verificationData')
            .doc(profile.uid) // Use the user's UID
            .set(verificationData.toMap());
      } else {
        throw Exception('Profile data not found');
      }
    } catch (e) {
      print('Failed to save verification data: $e');
    }
  }
}
