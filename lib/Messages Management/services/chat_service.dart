import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../Booking Mangement/models/booking_model.dart';
import '../models/message_model.dart';
import '../models/startConversation_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger logger = Logger();

  Future<void> createConversation(StartConversationModel conversation) async {
    await _firestore
        .collection('conversations')
        .doc(conversation.conversationId)
        .set(conversation.toMap());
  }

  Future<String> generateConversationId() async {
    return _firestore.collection('conversations').doc().id;
  }

  Future<String?> getExistingConversationId(String senderId, String receiverId) async {
    // Query for conversations where senderId matches and receiverId matches
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a matching conversation is found, return the conversationId
      return querySnapshot.docs.first.id;  // This will return the conversationId
    }

    // Check for conversation where the roles are reversed (sender and receiver switched)
    final reverseQuerySnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .get();

    if (reverseQuerySnapshot.docs.isNotEmpty) {
      // If a matching conversation is found, return the conversationId
      return reverseQuerySnapshot.docs.first.id;  // This will return the conversationId
    }

    // Return null if no existing conversation is found
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

  Future<StartConversationModel?> getExistingConversation(String senderId, String receiverId) async {
    // Check if the conversation exists where senderId is the shop and receiverId is the car owner
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    // If no conversation found, check the reverse case where senderId is the car owner and receiverId is the shop
    if (querySnapshot.docs.isEmpty) {
      final reverseQuerySnapshot = await _firestore
          .collection('conversations')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: senderId)
          .get();

      // If found, return the reverse conversation
      if (reverseQuerySnapshot.docs.isNotEmpty) {
        return StartConversationModel.fromMap(reverseQuerySnapshot.docs.first.data());
      }
    }

    // If a conversation is found in the first query or reverse query
    if (querySnapshot.docs.isNotEmpty) {
      return StartConversationModel.fromMap(querySnapshot.docs.first.data());
    }

    // Return null if no conversation found in either case
    return null;
  }


  Future<String> initializeConversation(String serviceProviderUid, String carOwnerUid) async {
    try {
      // Check if the conversation exists
      StartConversationModel? existingConversation =
      await getExistingConversation(serviceProviderUid, carOwnerUid);

      if (existingConversation != null) {
        return existingConversation.conversationId;
      }

      // Generate new conversation
      String conversationId = await generateConversationId();

      // Fetch user details
      final carOwnerData = await fetchCarOwnerDetails(carOwnerUid);
      final shopData = await fetchProviderByUid(serviceProviderUid);

      // Create the new conversation
      StartConversationModel conversation = StartConversationModel(
        conversationId: conversationId,
        senderId: serviceProviderUid,
        receiverId: carOwnerUid,
        timestamp: DateTime.now(),
        shopName: shopData['shopName'] ?? 'Unknown Shop',
        shopProfilePhoto: shopData['profileImage'] ?? '',
        carOwnerFirstName: carOwnerData['firstName'] ?? '',
        carOwnerLastName: carOwnerData['lastName'] ?? '',
        carOwnerProfilePhoto: carOwnerData['profileImage'] ?? '',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        numberOfMessages: 0,
      );

      await createConversation(conversation);

      return conversationId;
    } catch (e) {
      logger.e('Error initializing conversation: $e');
      rethrow;
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

  Future<Map<String, dynamic>> fetchProviderByUid(String userId) async {
    DocumentSnapshot userSnapshot = await _firestore
        .collection('automotiveShops_profile')
        .doc(userId)
        .get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Service Provider not found');
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

  // Booking Messages
  // Accept
  Future<void> sendBookingConfirmationMessage(String conversationId, BookingModel booking) async {
    try {
      // Format the message text
      String messageText =
          "Hi ${booking.fullName}, your booking on ${booking.bookingDate} at ${booking.bookingTime} has been accepted!\n\n"
          "Service/s: ${booking.selectedService.join(', ')}\n"
          "Price: ${booking.totalPrice.toStringAsFixed(2)}\n"
          "Car: ${booking.carBrand} ${booking.carModel}, ${booking.carYear} (${booking.color})\n\n"
          "We’re ready to help you with your vehicle. See you soon!\n";

      // Create the message model
      final message = MessageModel(
        messageId: '',
        conversationId: conversationId,
        messageText: messageText,
        timestamp: DateTime.now(),
        senderId: booking.serviceProviderUid,
      );

      // Add the message to the database
      final messageRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(); // Generate a unique message ID

      message.messageId = messageRef.id; // Set the generated ID
      await messageRef.set(message.toMap());

      // Update the conversation details
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': message.messageText, // Update with message text
        'lastMessageTime': FieldValue.serverTimestamp(), // Use server timestamp for consistency
        'numberOfMessages': FieldValue.increment(1), // Increment message count
      });

      logger.i('Booking confirmation message sent successfully');
    } catch (e) {
      logger.e('Error sending booking confirmation message: $e');
      rethrow; // Propagate the error
    }
  }



  // Decline
  Future<void> sendBookingDeclineMessage(
      String conversationId,
      BookingModel booking,
      ) async {
    final messageText =
        "Hi ${booking.fullName}, we’re sorry, but your booking on ${booking.bookingDate} at ${booking.bookingTime} has been declined.\n\n"
        "Service/s: ${booking.selectedService.join(', ')}\n"
        "Price: ${booking.totalPrice.toStringAsFixed(2)}\n"
        "Car: ${booking.carBrand} ${booking.carModel}, ${booking.carYear} (${booking.color})\n\n"
        "Feel free to rebook or contact us if you need assistance!\n";

    final message = MessageModel(
      messageId: '',
      conversationId: conversationId,
      messageText: messageText,
      timestamp: DateTime.now(),
      senderId: booking.serviceProviderUid,
    );

    await ChatService().sendMessage(message);
  }

  // Done
  Future<void> sendBookingDoneMessage(
      String conversationId,
      BookingModel booking,
      ) async {
    final messageText =
        "Hi ${booking.fullName}, your service on ${booking.bookingDate} at ${booking.bookingTime} was completed.\n\n"
        "Service/s: ${booking.selectedService.join(', ')}\n"
        "Price: ${booking.totalPrice.toStringAsFixed(2)}\n"
        "Car: ${booking.carBrand} ${booking.carModel}, ${booking.carYear} (${booking.color})\n\n"
        "Thank you for choosing us! Let us know if you need anything else.\n";

    final message = MessageModel(
      messageId: '',
      conversationId: conversationId,
      messageText: messageText,
      timestamp: DateTime.now(),
      senderId: booking.serviceProviderUid,
    );

    await ChatService().sendMessage(message);
  }
}
