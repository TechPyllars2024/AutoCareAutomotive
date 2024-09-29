// enum VerificationStatus {
//   pending,
//   underReview,
//   verified,
//   rejected,
// }

class VerificationModel {
  final String uid;
  final String shopName;
  final String location;
  final String dateSubmitted;
  final String timeSubmitted;
  final String fileUrl;
  final String status;

  VerificationModel({
    required this.uid,
    required this.shopName,
    required this.location,
    required this.dateSubmitted,
    required this.timeSubmitted,
    required this.fileUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'location': location,
      'dateSubmitted': dateSubmitted,
      'timeSubmitted': timeSubmitted,
      'fileUrl': fileUrl,
      'status': status.toString().split('.').last,
    };
  }

  factory VerificationModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return VerificationModel(
      uid: uid,
      shopName: doc['shopName'] as String,
      location: doc['location'] as String,
      dateSubmitted: doc['dateSubmitted'] as String,
      timeSubmitted: doc['timeSubmitted'] as String,
      fileUrl: doc['fileUrl'] as String,
      status: doc['status'] as String,
    );
  }
}