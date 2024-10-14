class VerificationModel {
  final String serviceProviderUid;
  final String shopName;
  final String location;
  final String dateSubmitted;
  final String timeSubmitted;
  final String fileUrl;
  final String verificationStatus;

  VerificationModel({
    required this.serviceProviderUid,
    required this.shopName,
    required this.location,
    required this.dateSubmitted,
    required this.timeSubmitted,
    required this.fileUrl,
    required this.verificationStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': serviceProviderUid,
      'shopName': shopName,
      'location': location,
      'dateSubmitted': dateSubmitted,
      'timeSubmitted': timeSubmitted,
      'fileUrl': fileUrl,
      'verificationStatus': verificationStatus,
    };
  }

  factory VerificationModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return VerificationModel(
      serviceProviderUid: uid,
      shopName: doc['shopName'] as String,
      location: doc['location'] as String,
      dateSubmitted: doc['dateSubmitted'] as String,
      timeSubmitted: doc['timeSubmitted'] as String,
      fileUrl: doc['fileUrl'] as String,
      verificationStatus: doc['verificationStatus'],
    );
  }
}