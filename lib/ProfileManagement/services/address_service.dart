import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/automotive_address_model.dart';

class AddressService {
  late CollectionReference addressCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final logger = Logger();

  AddressService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      addressCollection = FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(user.uid)
          .collection('addresses');
    }
  }

  Future<List<AutomotiveAddressModel>> fetchAddresses() async {
    try {
      final snapshot = await addressCollection.get();
      return snapshot.docs
          .map((doc) => AutomotiveAddressModel.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.i('Error fetching addresses: $e');
      throw Exception('Unable to load addresses. Please try again later.');
    }
  }

  Future<void> addAddress(AutomotiveAddressModel address) async {
    try {
      await addressCollection.add(address.toMap());
    } catch (e) {
      logger.i('Error adding addresses: $e');
      throw Exception('Could not save the address. Please try again.');
    }
  }

  Future<void> editAddress(String docId, AutomotiveAddressModel address) async {
    try {
      await addressCollection.doc(docId).update(address.toMap());
    } catch (e) {
      logger.i('Error editing address: $e');
      throw Exception('Failed to update the address. Please try again.');
    }
  }

  Future<void> deleteAddress(String docId) async {
    try {
      await addressCollection.doc(docId).delete();
    } catch (e) {
      logger.i('Error deleting address: $e');
      throw Exception('Could not delete the address. Please try again.');
    }
  }
}

class CapitalizeEachWordFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter of each word
    String text = newValue.text
        .split(' ') // Split the input text by spaces to get individual words
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' '); // Rejoin the words with spaces

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
