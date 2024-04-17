import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/grpc_call_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/grpc_chat_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/initialize_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_call/grpc_call_service.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/register_device_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/end_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/hold_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/make_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/connect_to_grpc_channel_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_updates_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_connect_status_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/initialize/init_grpc_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());
  locator.registerLazySingleton<SharedPreferencesGateway>(
      () => SharedPreferencesGateway());

  //Service
  locator.registerLazySingleton<InitializeService>(
      () => InitializeServiceImpl(locator.get(), locator.get()));
  locator.registerLazySingleton<GrpcChatService>(
      () => GrpcChatServiceImpl(locator.get(), locator.get()));
  locator.registerLazySingleton<GrpcCallService>(() => GrpcCallServiceImpl());
  locator
      .registerLazySingleton<AuthService>(() => AuthServiceImpl(locator.get()));

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
  locator.registerLazySingleton<InitGrpcUseCase>(
      () => GrpcInitImplUseCase(locator.get()),
      instanceName: "InitGrpcUseCase");
  locator.registerLazySingleton<ConnectToGrpcChannelUseCase>(
      () => ConnectToGrpcChannelImplUseCase(locator.get()),
      instanceName: "ConnectToGrpcChannelUseCase");
  locator.registerLazySingleton<FetchDialogsUseCase>(
      () => FetchDialogsImplUseCase(locator.get()),
      instanceName: "FetchDialogsUseCase");
  locator.registerLazySingleton<FetchUpdatesUseCase>(
      () => FetchUpdatesUseCaseImplUseCase(locator.get()),
      instanceName: "FetchUpdatesUseCase");
  locator.registerLazySingleton<SendDialogMessageUseCase>(
      () => SendDialogMessageImplUseCase(locator.get()),
      instanceName: "SendDialogMessageUseCase");
  locator.registerLazySingleton<MakeCallUseCase>(
      () => MakeCallImplUseCase(locator.get()),
      instanceName: "MakeCallUseCase");
  locator.registerLazySingleton<HoldCallUseCase>(
      () => HoldCallImplUseCase(locator.get()),
      instanceName: "HoldCallUseCase");
  locator.registerLazySingleton<EndCallUseCase>(
      () => EndCallImplUseCase(locator.get()),
      instanceName: "EndCallUseCase");
}
