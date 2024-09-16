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

  Future<String?> uploadImage(File image, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> updateProfileImages(File? coverImage, File? profileImage, String userId) async {
    String? coverImageUrl;
    String? profileImageUrl;

    if (coverImage != null) {
      coverImageUrl = await uploadImage(coverImage, 'users/$userId/cover.jpg');
    }

    if (profileImage != null) {
      profileImageUrl = await uploadImage(profileImage, 'users/$userId/profile.jpg');
    }

    await _firestore.collection('profile').doc(userId).update({
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    });
  }

  // Future<void> updateOperatingHours(Map<String, Map<String, String>> operatingHours, String userId) async {
  //   await _firestore.collection('users').doc(userId).update({
  //     'operatingHours': operatingHours,
  //   });
  // }

  Future<void> updateSelectedDays(Map<String, bool> selectedDays, String userId) async {
    await _firestore.collection('profile').doc(userId).update({
      'selectedDays': selectedDays,
    });
  }

  Future<List<String>> fetchSelectedDays(String userId) async {
    final doc = await _firestore.collection('profile').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('selectedDays')) {
      return List<String>.from(doc['selectedDays']);
    }
    return [];
  }

  // Future<void> updateOperatingHours(Map<String, Map<String, TimeOfDay>> operatingHours, String userId) async {
  //   final Map<String, Map<String, String>> formattedHours = operatingHours.map((day, hours) {
  //     return MapEntry(day, {
  //       'open': hours['open']!.format12Hour(),
  //       'close': hours['close']!.format12Hour(),
  //     });
  //   });

  //   await _firestore.collection('users').doc(userId).update({
  //     'operatingHours': formattedHours,
  //   });
  // }
}

// extension TimeOfDayExtension on TimeOfDay {
//   String format12Hour() {
//     final hour = this.hourOfPeriod == 0 ? 12 : this.hourOfPeriod;
//     final minute = this.minute.toString().padLeft(2, '0');
//     final period = this.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
// }