import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/automotive_shop_profile_model.dart';

class AutomotiveShopEditProfileServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

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
    final doc = await _firestore.collection('automotiveShops_profile').doc(uid).get();
    if (doc.exists) {
      return AutomotiveProfileModel.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> saveProfile({
    required String uid,
    required String serviceProviderUid,
    required String shopName,
    required String location,
    required File? coverImage,
    required File? profileImage,
    required List<String> daysOfTheWeek,
    required String operationTime,
    required List<String> serviceSpecialization,
    required String verificationStatus
  }) async {
    final Map<String, dynamic> updatedData = {};

    if (coverImage != null) {
      updatedData['coverImage'] = await uploadImage(coverImage, 'automotiveCoverImages/$uid.jpg');
    }

    if (profileImage != null) {
      updatedData['profileImage'] = await uploadImage(profileImage, 'automotiveProfileImages/$uid.jpg');
    }

    updatedData['serviceProviderUid'] = serviceProviderUid;
    updatedData['shopName'] = shopName;
    updatedData['location'] = location;
    updatedData['daysOfTheWeek'] = daysOfTheWeek;
    updatedData['operationTime'] = operationTime;
    updatedData['serviceSpecialization'] = serviceSpecialization;
    updatedData['verificationStatus'] = verificationStatus;

    final docRef = _firestore.collection('automotiveShops_profile').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      // Update the existing document
      await docRef.update(updatedData);
    } else {
      // Create a new document
      await docRef.set(updatedData);
    }
  }
}
