class AutomotiveProfileModel {
  final String uid;
  final String shopName;
  final String location;
  final String coverImage;
  final String profileImage;
  // final List<String> dayOfTheWeek;
  

  AutomotiveProfileModel({
    required this.uid,
    required this.shopName,
    required this.location,
    required this.coverImage,
    required this.profileImage,
    // required this.dayOfTheWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'location': location,
      'coverImage': coverImage,
      'profileImage': profileImage,
      // 'dayOfTheWeek': dayOfTheWeek,
    };
  }
  
  factory AutomotiveProfileModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return AutomotiveProfileModel(
      uid: uid,
      shopName: doc['shopName'] ?? '',
      location: doc['location'] ?? '',
      coverImage: doc['coverImage'] ?? '',
      profileImage: doc['profileImage'] ?? '',
      // dayOfTheWeek: List<String>.from(doc['dayOfTheWeek'] ?? []),
    );
  }
}

