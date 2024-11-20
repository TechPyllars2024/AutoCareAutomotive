import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../models/automotive_marker_model.dart';

class MapService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Collection name in Firestore for storing markers
  final String collectionName = "markers";
  final Logger logger = Logger();

  /// Add a marker to Firestore
  Future<void> addMarker(MarkerModel marker) async {
    try {
      await firestore.collection('markers').add(marker.toMap());
      logger.i("Marker added successfully!");
    } catch (e) {
      logger.e("Error adding marker: $e");
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            logger.e(
                "Permission denied. Check Firestore rules or user authentication.");
            break;
          default:
            logger.e("Unhandled FirebaseException: ${e.code}");
        }
      }
    }
  }

  Future<void> updateMarker(MarkerModel existingMarker, LatLng newPosition, String placeName) async {
    // Find the document where serviceProviderUid matches the existingMarker's serviceProviderUid
    final snapshot = await firestore
        .collection('markers')
        .where('serviceProviderUid', isEqualTo: existingMarker.serviceProviderUid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final documentId = snapshot.docs.first.id; // Get the document ID from the query result

      await firestore.collection('markers').doc(documentId).update({
        'nameOfThePlace': placeName,
        'latitude': newPosition.latitude,
        'longitude': newPosition.longitude,
      });
    } else {
      // Handle the case where the marker with the provided serviceProviderUid doesn't exist
      throw Exception('Marker not found for this service provider UID');
    }
  }


  Future<MarkerModel?> fetchMarkerByUserId(String userId) async {
    // Query the collection to find the document where serviceProviderUid matches the userId
    final snapshot = await firestore
        .collection('markers')
        .where('serviceProviderUid', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return MarkerModel(
        serviceProviderUid: userId,
        nameOfThePlace: data['nameOfThePlace'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        title: data['title'],
        snippet: data['snippet'],
      );
    }
    return null; // Return null if no document matches the userId
  }


  /// Fetch markers from Firestore
  Future<List<Marker>> fetchMarkersFromFirestore() async {
    try {
      QuerySnapshot snapshot = await firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: data['snippet'],
          ),
        );
      }).toList();
    } catch (e) {
      logger.i("Error fetching markers: $e");
      return [];
    }
  }
}
