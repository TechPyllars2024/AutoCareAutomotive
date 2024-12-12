import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../models/startConversation_model.dart';
import 'chatScreen.dart';

class AutomotiveMessagesScreen extends StatefulWidget {
  const AutomotiveMessagesScreen({super.key, this.child});

  final Widget? child;

  @override
  State<AutomotiveMessagesScreen> createState() => _AutomotiveMessagesScreenState();
}

class _AutomotiveMessagesScreenState extends State<AutomotiveMessagesScreen> {
  final ChatService _chatService = ChatService();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Stream<DocumentSnapshot> _listenToShopDetails(String senderId, String receiverId, String currentUserId) {
    // Determine which ID represents the shop
    String shopId = senderId == currentUserId ? receiverId : senderId;

    // Listen to shop details based on the identified shopId
    return FirebaseFirestore.instance
        .collection('car_owner_profile')
        .doc(shopId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _currentUserId.isEmpty
          ? const Center(
        child: Text(
          'Loading user information...',
          style: TextStyle(color: Colors.orange),
        ),
      )
          : StreamBuilder<List<StartConversationModel>>(
        stream: _chatService.getUserConversations(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading conversations...'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading messages.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          final conversations = snapshot.data!
              .where((conversation) => conversation.lastMessage.isNotEmpty)
              .toList();
          if (conversations.isEmpty) {
            return const Center(
              child: Text('No conversations yet.'),
            );
          }
          conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final isRead = conversation.isRead;

              return StreamBuilder<DocumentSnapshot>(
                stream: _listenToShopDetails(conversation.receiverId, conversation.senderId, _currentUserId!),
                builder: (context, shopSnapshot) {
                  if (shopSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(conversation.shopName),
                      subtitle: Text(conversation.lastMessage),
                    );
                  }
                  if (shopSnapshot.hasError) {
                    return const ListTile(
                      title: Text(
                        'Error loading car owner details.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  final carOwnerDetails = shopSnapshot.data!;
                  final carOwnerFirstName = carOwnerDetails['firstName'] ?? '';
                  final carOwnerLastName = carOwnerDetails['lastName'] ?? '';
                  final carOwnerProfilePhoto = carOwnerDetails['profileImage'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: carOwnerProfilePhoto.isNotEmpty
                          ? NetworkImage(carOwnerProfilePhoto)
                          : null,
                      child: carOwnerProfilePhoto.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      '$carOwnerFirstName $carOwnerLastName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      DateFormat.jm().format(conversation.lastMessageTime),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            carOwnerUid: conversation.senderId == _currentUserId
                                ? conversation.receiverId
                                : conversation.senderId,
                            conversationId: conversation.conversationId,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          conversation.carOwnerFirstName = result['firstName'];
                          conversation.carOwnerLastName = result['lastName'];
                          conversation.carOwnerProfilePhoto = result['profileImage'];
                        });
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
