import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/grpc_call_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/grpc_chat_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/initialize_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_call/grpc_call_service.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/end_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/hold_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_call/make_call_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/connect_to_grpc_channel_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_updates_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';

import '../domain/usecase/initialize/init_grpc_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());

  //Service
  locator.registerLazySingleton<InitializeService>(
      () => InitializeServiceImpl(locator.get()));
  locator.registerLazySingleton<GrpcChatService>(
      () => GrpcChatServiceImpl(locator.get()));
  locator.registerLazySingleton<GrpcCallService>(() => GrpcCallServiceImpl());

  //Use case
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
