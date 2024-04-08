import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final String content;

  const MessageItem({
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8, left: 200, right: 20),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.yellow.withOpacity(0.2),
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
