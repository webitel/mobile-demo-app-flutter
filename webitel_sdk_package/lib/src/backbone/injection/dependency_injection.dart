import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/connect_status_listener_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/grpc_chat_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';
import 'package:webitel_sdk_package/src/domain/services/connect_status_listener/connect_status_listener_service.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/login_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/register_device_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/connect_status_listener/listen_connect_status_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_message_updates.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_messages.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());
  locator.registerLazySingleton<ConnectListenerGateway>(
      () => ConnectListenerGateway(locator.get()));

  //Service
  locator.registerLazySingleton<GrpcChatService>(
      () => GrpcChatServiceImpl(locator.get(), locator.get()));
  locator.registerLazySingleton<AuthService>(
      () => AuthServiceImpl(locator.get(), locator.get()));
  locator.registerLazySingleton<ConnectStatusListenerService>(
      () => ConnectStatusListenerServiceImpl(locator.get()));

  //Use case
  locator.registerLazySingleton<RegisterDeviceUseCase>(
      () => RegisterDeviceImplUseCase(locator.get()),
      instanceName: "RegisterDeviceUseCase");
  locator.registerLazySingleton<LogoutUseCase>(
      () => LogoutImplUseCase(locator.get()),
      instanceName: "LogoutUseCase");
  locator.registerLazySingleton<ListenConnectStatusUseCase>(
      () => ListenConnectStatusImplUseCase(locator.get()),
      instanceName: "ListenConnectStatusUseCase");
  locator.registerLazySingleton<ListenToMessagesUsecase>(
      () => ListenToMessagesImplUseCase(locator.get()),
      instanceName: "ListenToOperatorMessagesUsecase");
  locator.registerLazySingleton<LoginUseCase>(
      () => LoginImplUseCase(locator.get()),
      instanceName: "LoginUseCase");
  locator.registerLazySingleton<FetchMessagesUseCase>(
      () => FetchMessagesImplUseCase(locator.get()),
      instanceName: "FetchMessagesUseCase");
  locator.registerLazySingleton<FetchMessageUpdatesUseCase>(
      () => FetchMessageUpdatesImplUseCase(locator.get()),
      instanceName: "FetchMessageUpdatesUseCase");
  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");
}
