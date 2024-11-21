import 'package:cloud_firestore/cloud_firestore.dart';

class StartConversationModel {
  String conversationId;
  String senderId;
  String receiverId;
  DateTime timestamp;
  String shopName;
  String shopProfilePhoto;
  String carOwnerFirstName;
  String carOwnerLastName;
  String carOwnerProfilePhoto;
  String lastMessage;
  DateTime lastMessageTime;
  int numberOfMessages;
  bool isRead;

  StartConversationModel({
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.shopName,
    required this.shopProfilePhoto,
    required this.carOwnerFirstName,
    required this.carOwnerLastName,
    required this.carOwnerProfilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.numberOfMessages,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'shopName': shopName,
      'shopProfilePhoto': shopProfilePhoto,
      'carOwnerFirstName': carOwnerFirstName,
      'carOwnerLastName': carOwnerLastName,
      'carOwnerProfile': carOwnerProfilePhoto,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'numberOfMessages': numberOfMessages,
      'isRead': isRead,
    };
  }

  factory StartConversationModel.fromMap(Map<String, dynamic> map) {
    return StartConversationModel(
      conversationId: map['conversationId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
      shopName: map['shopName'] ?? '',
      shopProfilePhoto: map['shopProfilePhoto'] ?? '',
      carOwnerFirstName: map['senderFirstName'] ?? '',
      carOwnerLastName: map['senderLastName'] ?? '',
      carOwnerProfilePhoto: map['senderProfilePhoto'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] is Timestamp
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : DateTime.parse(map['lastMessageTime']))
          : DateTime.now(),
      numberOfMessages: map['numberOfMessages'] ?? 0,
      isRead: map['isRead'] ?? false,
    );
  }
}