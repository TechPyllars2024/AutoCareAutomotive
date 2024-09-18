import 'package:autocare_automotiveshops/ProfileManagement/models/automotive_shop_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutomotiveShopEditProfileServices {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickCoverImage() async {
    return await pickImage();
  }

  Future<File?> pickProfileImage() async {
    return await pickImage();
  }

// Future<String> _uploadImage(File image, String path) async {
//   final ref = FirebaseStorage.instance.ref().child(path);
//   await ref.putFile(image);
//   return await ref.getDownloadURL();
// }

// Future<void> saveProfile({
//   required String uid,
//   required TextEditingController shopNameController,
//   required TextEditingController locationController,
//   required File? coverImage,
//   required File? profileImage,
//   required BuildContext context,
// }) async {
//   final user = FirebaseAuth.instance.currentUser;

//   if (user != null) {
//     List<String> emptyFields = [];

//     if (shopNameController.text.isEmpty) {
//       emptyFields.add('Shop Name');
//     }

//     if (locationController.text.isEmpty) {
//       emptyFields.add('Location');
//     }

//     if (emptyFields.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('The following fields are empty: ${emptyFields.join(', ')}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Map<String, dynamic> updatedData = {};

//     if (coverImage != null) {
//       final coverImageUrl = await _uploadImage(coverImage, 'coverImages/$uid.jpg');
//       updatedData['coverImage'] = coverImageUrl;
//     }

//     if (profileImage != null) {
//       final profileImageUrl = await _uploadImage(profileImage, 'profileImages/$uid.jpg');
//       updatedData['profileImage'] = profileImageUrl;
//     }

//     updatedData['shopName'] = shopNameController.text;
//     updatedData['location'] = locationController.text;

//     if (coverImage != null) {
//       final coverImageUrl = await _uploadImage(coverImage, 'coverImages/$uid.jpg');
//       updatedData['coverImage'] = coverImageUrl;
//     }

//     if (profileImage != null) {
//       final profileImageUrl = await _uploadImage(profileImage, 'profileImages/$uid.jpg');
//       updatedData['profileImage'] = profileImageUrl;
//     }
//   } else {
//     print('User ID is null or images are not selected');
//   }
// }
}