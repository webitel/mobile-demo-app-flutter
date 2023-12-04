import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationBar(context),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("// TODO"),
        ],
      ),
    );
  }

  CupertinoNavigationBar buildNavigationBar(BuildContext context) {
    return const CupertinoNavigationBar(backgroundColor: Colors.grey);
  }
}
