class AutomotiveShopProfileModel {
  String uid;
  String backgroundImage;
  String profileImage;
  String shopName;
  String location;
  List<String> daysOfWeek;
  Map<String, String> operatingHours;

  AutomotiveShopProfileModel({
    required this.uid,
    required this.backgroundImage,
    required this.profileImage,
    required this.shopName,
    required this.location,
    required this.daysOfWeek,
    required this.operatingHours,
  });

  // Convert AutomotiveShopProfile to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'backgroundImage': backgroundImage,
      'profileImage': profileImage,
      'shopName': shopName,
      'location': location,
      'daysOfWeek': daysOfWeek,
      'operatingHours': operatingHours,
    };
  }

  // Create AutomotiveShopProfile from a Map
  factory AutomotiveShopProfileModel.fromMap(Map<String, dynamic> map) {
    return AutomotiveShopProfileModel(
      uid: map['uid'] ?? '',
      backgroundImage: map['backgroundImage'] ?? '',
      profileImage: map['profileImage'] ?? '',
      shopName: map['shopName'] ?? '',
      location: map['location'] ?? '',
      daysOfWeek: List<String>.from(map['daysOfWeek'] ?? []),
      operatingHours: Map<String, String>.from(map['operatingHours'] ?? {}),
    );
  }
}