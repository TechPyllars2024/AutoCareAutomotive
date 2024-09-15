class AutomotiveShopProfile {
  String backgroundImage;
  String profileImage;
  String shopName;
  String location;
  List<String> daysOfWeek;
  Map<String, String> operatingHours;

  AutomotiveShopProfile({
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
      'backgroundImage': backgroundImage,
      'profileImage': profileImage,
      'shopName': shopName,
      'location': location,
      'daysOfWeek': daysOfWeek,
      'operatingHours': operatingHours,
    };
  }

  // Create AutomotiveShopProfile from a Map
  factory AutomotiveShopProfile.fromMap(Map<String, dynamic> map) {
    return AutomotiveShopProfile(
      backgroundImage: map['backgroundImage'] ?? '',
      profileImage: map['profileImage'] ?? '',
      shopName: map['shopName'] ?? '',
      location: map['location'] ?? '',
      daysOfWeek: List<String>.from(map['daysOfWeek'] ?? []),
      operatingHours: Map<String, String>.from(map['operatingHours'] ?? {}),
    );
  }
}