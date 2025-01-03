class AutomotiveProfileModel {
  final String uid;
  final String serviceProviderUid;
  final String shopName;
  final String location;
  final String coverImage;
  final String profileImage;
  final List<String> daysOfTheWeek;
  final String operationTime;
  final List<String> serviceSpecialization;
  final String verificationStatus;
  final double totalRatings;
  final int numberOfRatings;
  final int numberOfBookingsPerHour;
  final Map<String, Map<String, int>> remainingSlots;
  final double commissionLimit;

  // Constructor for creating an instance of AutomotiveProfileModel
  AutomotiveProfileModel(
      {required this.uid,
      required this.serviceProviderUid,
      required this.shopName,
      required this.location,
      required this.coverImage,
      required this.profileImage,
      required this.daysOfTheWeek,
      required this.operationTime,
      required this.serviceSpecialization,
      required this.verificationStatus,
      required this.totalRatings,
      required this.numberOfRatings,
      required this.numberOfBookingsPerHour,
      required this.remainingSlots,
      required this.commissionLimit
      });

  // Convert the model to a map for storage or transfer
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'serviceProviderUid': serviceProviderUid,
      'shopName': shopName,
      'location': location,
      'coverImage': coverImage,
      'profileImage': profileImage,
      'daysOfTheWeek': daysOfTheWeek,
      'operationTime': operationTime,
      'serviceSpecialization': serviceSpecialization,
      'verificationStatus': verificationStatus,
      'totalRatings': totalRatings,
      'numberOfRatings': numberOfRatings,
      'numberOfBookingsPerHour': numberOfBookingsPerHour,
      'remainingSlots': remainingSlots,
      'commissionLimit': commissionLimit
    };
  }

  // Create a model instance from a document snapshot
  factory AutomotiveProfileModel.fromDocument(
      Map<String, dynamic> doc, String uid) {
    return AutomotiveProfileModel(
        uid: uid,
        serviceProviderUid: doc['serviceProviderUid'] as String? ?? '',
        shopName: doc['shopName'] as String? ?? '',
        location: doc['location'] as String? ?? '',
        coverImage: doc['coverImage'] as String? ?? '',
        profileImage: doc['profileImage'] as String? ?? '',
        daysOfTheWeek: List<String>.from(doc['daysOfTheWeek'] ?? []),
        operationTime: doc['operationTime'] as String? ?? '',
        serviceSpecialization:
            List<String>.from(doc['serviceSpecialization'] ?? []),
        verificationStatus: doc['verificationStatus'] ?? '',
        totalRatings: doc['totalRatings']?.toDouble() ?? 0.0,
        numberOfRatings: doc['numberOfRatings'] ?? 0,
        numberOfBookingsPerHour: doc['numberOfBookingsPerHour'] ?? 0,
        commissionLimit: doc['commissionLimit']?.toDouble() ?? 0.0,
        remainingSlots:
            Map<String, Map<String, int>>.from(doc['remainingSlots'] ?? {}));
  }
}
