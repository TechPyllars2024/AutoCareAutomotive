class AutomotiveAddressModel {
  String houseNumberandStreet;
  String baranggay;
  String city;
  String province;
  String nearestLandmark;

  AutomotiveAddressModel({
    required this.houseNumberandStreet,
    required this.baranggay,
    required this.city,
    required this.province,
    required this.nearestLandmark,
  });

  Map<String, dynamic> toMap() {
    return {
      'houseNumberandStreet': houseNumberandStreet,
      'baranggay': baranggay,
      'city': city,
      'province': province,
      'nearestLandmark': nearestLandmark,
    };
  }

  factory AutomotiveAddressModel.fromMap(Map<String, dynamic> map) {
    return AutomotiveAddressModel(
      houseNumberandStreet: map['houseNumberandStreet'],
      nearestLandmark: map['nearestLandmark'],
      baranggay: map['baranggay'],
      city: map['city'],
      province: map['province'],
    );
  }
}
