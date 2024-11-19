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
