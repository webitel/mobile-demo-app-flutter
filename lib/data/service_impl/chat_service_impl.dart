import 'package:webitel_sdk/domain/entity/dialog_message.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

class ChatServiceImpl implements ChatService {
  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity}) {
    throw UnimplementedError();
  }
}
