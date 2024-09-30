import 'package:autocare_automotiveshops/ProfileManagement/services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import '../models/automotive_shop_getVerified_model.dart';
import '../models/automotive_shop_profile_model.dart';

class GetVerifiedServices {
  final ProfileService _profileService = ProfileService();
  final Logger logger = Logger();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDF files
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
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
          serviceProviderUid: profile.uid,
          shopName: profile.shopName,
          location: profile.location,
          dateSubmitted: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          timeSubmitted: DateFormat('HH:mm').format(DateTime.now()),
          fileUrl: fileUrl,
          verificationStatus: 'Pending',
        );

        await FirebaseFirestore.instance
            .collection('verificationData')
            .doc(profile.uid)
            .set(verificationData.toMap());
      } else {
        throw Exception('Profile data not found');
      }
    } catch (e) {
      logger.i('Failed to save verification data: $e');
    }
  }

  Future<String?> fetchStatus(String serviceProviderUid) async {
      try {
        final doc = await firestore
            .collection('automotiveShops_profile')
            .doc(serviceProviderUid)
            .get();
        final data = doc.data();

        if (data != null) {
          // Extract only firstName and lastName from the document data
          final String status = data['verificationStatus'] ?? '';

          // Return the full name concatenated
          logger.i('User profile data found',status);
          return status;
        } else {
          logger.i('No profile data found for user');
          return null; // Return null if no data found
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }
  }