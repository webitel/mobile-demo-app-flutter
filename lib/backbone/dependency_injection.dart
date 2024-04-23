import 'package:get_it/get_it.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk/data/service_impl/chat_service_impl.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';
import 'package:webitel_sdk/domain/usecase/auth/login_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/fetch_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/send_dialog_message_usecase.dart';
import 'package:webitel_sdk/presentation/bloc/auth/auth_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());
  locator.registerLazySingleton<DatabaseProvider>(() => DatabaseProvider());

  //Service
  locator
      .registerLazySingleton<ChatService>(() => ChatServiceImpl(locator.get()));
  locator
      .registerLazySingleton<AuthService>(() => AuthServiceImpl(locator.get()));

  //Use case

  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");

  locator.registerLazySingleton<FetchMessagesUseCase>(
      () => FetchMessagesImplUseCase(locator.get()),
      instanceName: "FetchMessagesUseCase");
  locator.registerLazySingleton<ListenToMessagesUseCase>(
      () => ListenToMessagesImplUseCase(locator.get()),
      instanceName: "ListenToMessagesUseCase");
  locator.registerLazySingleton<LoginUseCase>(
      () => LoginImplUseCase(locator.get()),
      instanceName: "LoginUseCase");

  //BloC
  locator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      locator<ListenToMessagesUseCase>(instanceName: "ListenToMessagesUseCase"),
      locator<FetchMessagesUseCase>(instanceName: "FetchMessagesUseCase"),
      locator<SendDialogMessageUseCase>(
          instanceName: "SendDialogMessageUseCase"),
    ),
  );
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      locator<LoginUseCase>(instanceName: "LoginUseCase"),
    ),
  );
}
