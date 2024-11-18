import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import 'fullViewImage.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final List<String> allImageUrls;

  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.allImageUrls, // Add this line
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final messageTime = timeFormat.format(message.timestamp);

    return Transform.translate(
      offset: isMe ? const Offset(-10, 0) : const Offset(10, 0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isMe ? Colors.orange.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageView(
                            imageUrls: allImageUrls, // Pass the list of all image URLs
                            initialIndex: allImageUrls.indexOf(message.imageUrl!), // Set the initial index
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 130,
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Text(
                    message.messageText,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                const SizedBox(height: 5),
                Text(
                  messageTime,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}