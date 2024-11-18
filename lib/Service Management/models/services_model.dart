class ServiceModel {
  final String uid;
  final String serviceId;
  final String name;
  final String description;
  final double price;
  final String servicePicture;
  final List<String> category;

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