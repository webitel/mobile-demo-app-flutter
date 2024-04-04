import 'package:flutter/material.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

import 'presentation/page/chat.dart';

void main() async {
  runApp(const MyApp());
  await WebitelSdkPackage().registerDependencies();
  await WebitelSdkPackage().initGrpc();
  await WebitelSdkPackage().connectToGrpcChannel(
    deviceId: 'some id',
    clientToken:
        '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
    accessToken:
        'eyJhbGciOiJSUzI1NiIsImtpZCI6Im1YRjdVdzhMb2JOWERUQUVrbVh1ZFEiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJodHRwczovL2FwaS5wb3MuZmhsLndvcmxkIiwiZXhwIjoxNzEzMTgyNDAwLCJpYXQiOjE3MTIxNDU5NjAsImlpZCI6Imp3dF9mbHV0dGVyX2RlbW9fY3VzdG9tZXJfaWQiLCJpc3MiOiJodHRwczovL2Rldi53ZWJpdGVsLmNvbS9wb3J0YWwiLCJqdGkiOiIiLCJuYW1lIjoiVm9sb2R5bXlyIEh1bmthbG8gKEpXVCkiLCJuYmYiOjE3MTIxNDU5NjAsInBsdGYiOiJOQVRJVkUiLCJyb2xlIjoiY2xpZW50Iiwic2NvcGUiOlsib2ZmbGluZV9hY2Nlc3MiLCJvcGVuaWQiLCJwb3MtY2xpZW50IiwicG9zLWNsaWVudC11bnZlcmlmaWVkIl0sInN1YiI6IjVkZDY5MzM5NTcwNTNhOTBiYTdkYTBhMTM2MjQ0MzNmIiwidWlkIjoiY2Q2Njk3ZjctOTg4ZS00MmU3LWFhYWYtYWNhMWI5MmU0ZWI5In0.PwoYx0PY8IUrPHLwj2cYXhOT7jPcoT3jUMUJMH5k1yLcQow326lo5JLQ7FJG4KdwFMuHEBYbr749Ht021tTsKFDdZFozPWjqI0xz6--NInSFRX_YzrHX2bL6pUrqj7iH8rnii8aQrqAS-26jIQo3OxKdQY_-Tun6YJXd28Li-1Pfa-u0Bwo27z_0JKDtpVJ1JMfQIaF6MXo76ZC6CPfem_VVFqUk2mNwVBsZ0J8me3THBVgawNgFKQKpb2K3Zm1yxECOyL3J8yRf-Ek626wJTPFhLaHMBhEvq5dGHmwurISgGUEDcDcpoEibC97TG0nIelGNy4bW_oPjn_2VkBUTCw',
  );
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
