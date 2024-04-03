import 'package:flutter/material.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              WebitelSdkPackage().ping();
            },
            child: const Text('Ping Test')),
      ),
    );
  }
}
