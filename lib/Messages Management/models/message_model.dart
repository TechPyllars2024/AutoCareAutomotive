class MessageModel {
  String messageId;
  String conversationId;
  String messageText;
  DateTime timestamp;
  String messageType;
  String senderId;
  String? imageUrl;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.messageText,
    required this.timestamp,
    this.messageType = 'text',
    required this.senderId,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'senderId': senderId,
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      messageId: id,
      conversationId: data['conversationId'] ?? '',
      messageText: data['messageText'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      messageType: data['messageType'] ?? 'text',
      senderId: data['senderId'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  MessageModel copyWith({String? messageId, String? imageUrl, String? messageType}) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId,
      messageText: messageText,
      timestamp: timestamp,
      messageType: messageType ?? this.messageType,
      senderId: senderId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
