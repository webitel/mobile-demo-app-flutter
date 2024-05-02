import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

class MessageItem extends StatelessWidget {
  final String content;
  final MessageType messageType;

  final String filePath;

  const MessageItem({
    required this.messageType,
    required this.content,
    required this.filePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(20),
          topLeft: Radius.circular(messageType == MessageType.user ? 20 : 0),
          bottomLeft: const Radius.circular(20),
          bottomRight:
              Radius.circular(messageType == MessageType.operator ? 20 : 0),
        ),
        color: messageType == MessageType.user
            ? Colors.yellow.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (filePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(filePath),
                ),
              ),
            if (filePath.isNotEmpty) const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Bebas',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
