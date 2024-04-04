import 'package:get_it/get_it.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/service_impl/auth_service_impl.dart';
import 'package:webitel_sdk_package/src/data/service_impl/initialize_service_impl.dart';
import 'package:webitel_sdk_package/src/domain/services/authorization/auth_service.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/ping_usecase.dart';

import '../domain/usecase/initialize/init_grpc_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> registerDi() async {
  //Gateway
  if (!locator.isRegistered<GrpcGateway>(instanceName: "GrpcGateway")) {
    locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());
  }

  //Service

  if (!locator.isRegistered<InitializeService>(
      instanceName: "InitializeServiceImpl")) {
    locator.registerLazySingleton<InitializeService>(
        () => InitializeServiceImpl(locator.get()));
  }

  if (!locator.isRegistered<AuthService>(instanceName: "AuthServiceImpl")) {
    locator.registerLazySingleton<AuthService>(
        () => AuthServiceImpl(locator.get()));
  }

  //Use case

  if (!locator.isRegistered<InitGrpcUseCase>(instanceName: "InitGrpcUseCase")) {
    locator.registerLazySingleton<InitGrpcUseCase>(
        () => GrpcInitImplUseCase(locator.get()),
        instanceName: "GrpcInitImplUseCase");
  }

  if (!locator.isRegistered<PingUseCase>(instanceName: "PingUseCase")) {
    locator.registerLazySingleton<PingUseCase>(
        () => GrpcPingUseCase(locator.get()),
        instanceName: "GrpcPingUseCase");
  }
}
