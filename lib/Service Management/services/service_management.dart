import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/services_model.dart';
import 'image_service.dart';

class ServiceManagement {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ImageService imageService = ImageService();

  // Add a new service with an optional image
  Future<String> addService({
    required String serviceProviderId,
    required String name,
    required String description,
    required double price,
    required String category,
    File? imageFile,
  }) async {
    try {
      String serviceId = firestore.collection("services").doc().id;
      String? servicePictureUrl;

      // If an image is selected, upload it
      if (imageFile != null) {
        servicePictureUrl = await imageService.uploadImage(imageFile, 'service_images/$serviceId');
      }

      // Create the new service model
      ServiceModel newService = ServiceModel(
        uid: serviceProviderId,
        serviceId: serviceId,
        name: name,
        description: description,
        price: price,
        category: [category],
        servicePicture: servicePictureUrl ?? '',
      );

      // Add the new service to Firestore
      await firestore.collection("services").doc(serviceId).set(newService.toMap());

      return 'Service added successfully';
    } catch (e) {
      return 'Failed to add service: $e';
    }
  }

  // Update existing service
  Future<String> updateService({
    required String serviceId,
    required String name,
    required String description,
    required double price,
    required String category,
    File? imageFile,
  }) async {
    try {
      String? servicePictureUrl;

      // If a new image is selected, upload it
      if (imageFile != null) {
        servicePictureUrl = await imageService.uploadImage(imageFile, 'service_images/$serviceId');
      }

      // Prepare the updated data
      Map<String, dynamic> updatedService = {
        'name': name,
        'description': description,
        'price': price,
        'category': [category],
      };

      // If an image URL exists, update the service picture
      if (servicePictureUrl != null) {
        updatedService['servicePicture'] = servicePictureUrl;
      }

      // Update the service in Firestore
      await firestore.collection("services").doc(serviceId).update(updatedService);

      return 'Service updated successfully';
    } catch (e) {
      return 'Failed to update service: $e';
    }
  }

  // Fetch all services for a particular service provider
  Stream<List<ServiceModel>> fetchServices(String serviceProviderId) {
    return firestore
        .collection('services')
        .where('uid', isEqualTo: serviceProviderId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ServiceModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    await firestore.collection('services').doc(serviceId).delete();
  }
}
