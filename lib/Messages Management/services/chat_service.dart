import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';
import '../models/startConversation_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createConversation(StartConversationModel conversation) async {
    await _firestore
        .collection('conversations')
        .doc(conversation.conversationId)
        .set(conversation.toMap());
  }

  Future<String> generateConversationId() async {
    return _firestore.collection('conversations').doc().id;
  }

  Future<StartConversationModel?> getExistingConversation(String senderId, String receiverId) async {
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return StartConversationModel.fromMap(querySnapshot.docs.first.data());
    }

    return null;
  }

  Stream<List<StartConversationModel>> getUserConversations(String shopId) {
    return _firestore
        .collection('conversations')
        .where('receiverId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => StartConversationModel.fromMap(doc.data()))
        .toList());
  }

  Future<String> initializeConversation(String currentUserId, String serviceProviderUid) async {
    StartConversationModel? existingConversation = await getExistingConversation(currentUserId, serviceProviderUid);

    if (existingConversation != null) {
      return existingConversation.conversationId;
    } else {
      final newConversationId = await generateConversationId();
      final newConversation = StartConversationModel(
        conversationId: newConversationId,
        senderId: currentUserId,
        receiverId: serviceProviderUid,
        timestamp: DateTime.now(),
        shopName: 'Shop Name',
        shopProfilePhoto: 'Car Owner Profile Photo URL',
        carOwnerFirstName: 'Name',
        carOwnerLastName: 'Name',
        carOwnerProfilePhoto: 'Shop Profile Photo URL',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        numberOfMessages: 0,
      );

      await createConversation(newConversation);
      return newConversationId;
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'isRead': true,
    });
  }

  Future<void> sendMessage(MessageModel message, {File? imageFile}) async {
    try {
      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile);
        message = message.copyWith(imageUrl: imageUrl, messageType: 'image');
      }

      final messageId = _firestore.collection('conversations').doc().id;
      message = message.copyWith(messageId: messageId);

      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .update({
        'lastMessage': message.messageText.isNotEmpty ? message.messageText : 'Image',
        'lastMessageTime': message.timestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageRef = _storage.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
      final numberOfMessages = messages.length;

      _updateMessageCount(conversationId, numberOfMessages);

      return messages;
    });
  }

  Future<void> _updateMessageCount(String conversationId, int count) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'numberOfMessages': count});
    } catch (e) {
      print('Error updating message count: $e');
    }
  }

  Future<StartConversationModel> fetchStartConversationById(String conversationId) async {
    final startConversationData = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .get();

    if (startConversationData.exists) {
      return StartConversationModel.fromMap(startConversationData.data()!);
    } else {
      throw Exception('Conversation not found');
    }
  }

  Future<Map<String, dynamic>> fetchCarOwnerDetails(String userId) async {
    DocumentSnapshot userSnapshot = await _firestore
        .collection('car_owner_profile')
        .doc(userId)
        .get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Car owner not found');
    }
  }

  Future<Map<String, dynamic>> fetchCarOwnerByUid(String uid) async {
    try {
      DocumentSnapshot carOwnerSnapshot = await _firestore
          .collection('car_owner_profile')
          .doc(uid)
          .get();

      if (carOwnerSnapshot.exists && carOwnerSnapshot.data() != null) {
        return carOwnerSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
