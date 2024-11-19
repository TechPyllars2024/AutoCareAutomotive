import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/automotive_address_model.dart';
import '../services/address_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final houseNumberandStreetController = TextEditingController();
  final baranggayController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final nearestLandmarkController = TextEditingController();

  List<AutomotiveAddressModel> addresses = [];
  late AddressService addressService;
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    houseNumberandStreetController.dispose();
    baranggayController.dispose();
    cityController.dispose();
    provinceController.dispose();
    nearestLandmarkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    addressService = AddressService();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      // Fetch the saved address for the current user
      final fetchedAddresses = await addressService.fetchAddresses();
      setState(() {
        addresses = fetchedAddresses;
        _isLoading = false;

        // If there is an address saved, populate the text controllers
        if (addresses.isNotEmpty) {
          final address = addresses[0];
          houseNumberandStreetController.text = address.houseNumberandStreet;
          baranggayController.text = address.baranggay;
          cityController.text = address.city;
          provinceController.text = address.province;
          nearestLandmarkController.text = address.nearestLandmark;
        }
      });
    }
  }

  void _submitAddress() async {
    if (formKey.currentState!.validate()) {
      final newAddress = AutomotiveAddressModel(
        houseNumberandStreet: houseNumberandStreetController.text,
        baranggay: baranggayController.text,
        city: cityController.text,
        province: provinceController.text,
        nearestLandmark: nearestLandmarkController.text,
      );

      try {
        if (addresses.isEmpty) {
          // Add new address if no address exists
          await addressService.addAddress(newAddress);
        } else {
          final docId =
              (await addressService.addressCollection.get()).docs[0].id;
          // Edit the existing address by replacing the old one
          await addressService.editAddress(docId, newAddress);
        }

        // Fetch updated addresses
        await _fetchAddresses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved!')),
        );

        // Clear form and close
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fill in your address details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: houseNumberandStreetController,
                        decoration: const InputDecoration(
                          labelText: 'House Number / Street',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your house number and street';
                          } else if (value.length < 2 || value.length > 30) {
                            return 'Not a valid house number and street';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: baranggayController,
                        decoration: const InputDecoration(
                          labelText: 'Barangay',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a barangay';
                          } else if (value.length < 2 || value.length > 30) {
                            return 'Not a valid barangay';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'City/Municipality',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a city/municipality';
                          } else if (value.length < 2 || value.length > 30) {
                            return 'Not a valid city/municipality';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: provinceController,
                        decoration: const InputDecoration(
                          labelText: 'Province',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a province';
                          } else if (value.length < 2 || value.length > 30) {
                            return 'Not a valid province';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nearestLandmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Nearest Landmark',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a nearest landmark';
                          } else if (value.length < 2 || value.length > 50) {
                            return 'Not a valid nearest landmark';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade900,
                        ),
                        child: const Text(
                          'Save Address',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
