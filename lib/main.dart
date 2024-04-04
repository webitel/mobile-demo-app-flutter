import 'package:flutter/material.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

import 'chat_page.dart';

void main() async {
  runApp(const MyApp());
 await WebitelSdkPackage().registerDependencies();
  await WebitelSdkPackage().initGrpc();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: const ChatPage(),
    );
  }
}
