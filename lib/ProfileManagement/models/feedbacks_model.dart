import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackerName;
  final String feedbackId;
  final String bookingId;
  final String serviceProviderUid;
  final String carOwnerId;
  final int rating;
  final String comment;
  final DateTime timestamp;

  FeedbackModel({
    required this.feedbackerName,
    required this.feedbackId,
    required this.bookingId,
    required this.serviceProviderUid,
    required this.carOwnerId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> data, String id) {
    return FeedbackModel(
      feedbackerName: data['feedbackerName'] ?? '',
      feedbackId: id,
      bookingId: data['bookingId'] ?? '',
      serviceProviderUid: data['serviceProviderUid'] ?? '',
      carOwnerId: data['carOwnerId'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0) as int,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feedbackerName': feedbackerName,
      'feedbackId': feedbackId,
      'bookingId': bookingId,
      'serviceProviderUid': serviceProviderUid,
      'carOwnerId': carOwnerId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}