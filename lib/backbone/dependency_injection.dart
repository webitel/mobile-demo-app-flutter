import 'package:get_it/get_it.dart';
import 'package:webitel_sdk/data/service_impl/chat_service_impl.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk/domain/usecase/listen_incoming_operator_messages.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk/presentation/bloc/chat_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Service
  locator.registerLazySingleton<ChatService>(() => ChatServiceImpl());

  //Use case
  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");
  locator.registerLazySingleton<ListenIncomingOperatorUseCase>(
      () => ListenIncomingOperatorImplUseCase(locator.get()),
      instanceName: "ListenIncomingOperatorUseCase");

  //BloC
  locator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      locator<SendDialogMessageUseCase>(
          instanceName: "SendDialogMessageUseCase"),
      locator<ListenIncomingOperatorUseCase>(
          instanceName: "ListenIncomingOperatorUseCase"),
    ),
  );
}
