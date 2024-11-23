class ServiceModel {
  final String uid; //uid of the service provider
  final String serviceId;  // Unique ID for the service
  final String name;       // Name of the service
  final String description; // Detailed description of the service
  final double price;      // Price of the service
  final String servicePicture; // URL of the service picture
  final List<String> category;   // Category of the service

  ServiceModel({
    required this.uid,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.servicePicture,
    required this.category,
  });

  // Convert ServiceModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'servicePicture': servicePicture,
      'category': category,
    };
  }

  // Create ServiceModel from a Firestore document
  factory ServiceModel.fromMap(Map<String, dynamic> doc, String uid) {
    return ServiceModel(
      uid: uid,
      serviceId: doc['serviceId'] ?? '',
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      price: doc['price']?.toDouble() ?? 0.0,
      servicePicture: doc['servicePicture'] ?? '',
      category: List<String>.from(doc['category'] ?? []),
    );
  }
}