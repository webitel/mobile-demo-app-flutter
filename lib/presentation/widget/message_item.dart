import 'package:flutter/material.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

class MessageItem extends StatelessWidget {
  final String content;
  final MessageType messageType;

  const MessageItem({
    required this.messageType,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: messageType == MessageType.user
            ? Colors.yellow.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
      ),
      child: Center(
          child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      )),
    );
  }
}
