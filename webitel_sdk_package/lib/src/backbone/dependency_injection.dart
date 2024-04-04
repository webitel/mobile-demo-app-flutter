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
  locator.registerLazySingleton<GrpcGateway>(() => GrpcGateway());

  //Service
  locator.registerLazySingleton<InitializeService>(
      () => InitializeServiceImpl(locator.get()));
  locator
      .registerLazySingleton<AuthService>(() => AuthServiceImpl(locator.get()));

  //Use case
  locator.registerLazySingleton<InitGrpcUseCase>(
      () => GrpcInitImplUseCase(locator.get()),
      instanceName: "InitGrpcUseCase");
  locator.registerLazySingleton<PingUseCase>(
      () => GrpcPingUseCase(locator.get()),
      instanceName: "PingUseCase");
}
