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

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDF files
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null; // No file selected
    }
  }

  Future<String?> uploadFile(String filePath) async {
    File file = File(filePath);
    String fileName = file.path.split('/').last;

    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('getVerified/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> saveVerificationData(String fileUrl) async {
    try {
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
            .doc(profile.uid)
            .set(verificationData.toMap());
      } else {
        throw Exception('Profile data not found');
      }
    } catch (e) {
      print('Failed to save verification data: $e');
    }
  }
}