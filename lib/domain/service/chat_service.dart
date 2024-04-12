import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

abstract interface class ChatService {
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity dialogMessageEntity});
}
