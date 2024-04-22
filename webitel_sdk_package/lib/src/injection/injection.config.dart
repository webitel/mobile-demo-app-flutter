// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/gateway/channel_status_listener.dart' as _i9;
import '../data/gateway/connect_listener_gateway.dart' as _i10;
import '../data/gateway/grpc_gateway.dart' as _i5;
import '../data/gateway/shared_preferences_gateway.dart' as _i4;
import '../data/service_impl/auth_service_impl.dart' as _i7;
import '../data/service_impl/chat_list_service_impl.dart' as _i15;
import '../data/service_impl/chat_service_impl.dart' as _i13;
import '../data/service_impl/connect_status_listener_service_impl.dart' as _i23;
import '../data/service_impl/error_service_impl.dart' as _i21;
import '../database/request_database.dart' as _i3;
import '../domain/services/auth_service.dart' as _i6;
import '../domain/services/chat_list_service.dart' as _i14;
import '../domain/services/connect_status_listener_service.dart' as _i22;
import '../domain/services/error_service.dart' as _i20;
import '../domain/services/grpc_chat_service.dart' as _i12;
import '../domain/usecase/auth/login_usecase.dart' as _i8;
import '../domain/usecase/auth/logout_usecase.dart' as _i11;
import '../domain/usecase/auth/register_device_usecase.dart' as _i16;
import '../domain/usecase/chat/fetch_message_updates.dart' as _i19;
import '../domain/usecase/chat/fetch_messages.dart' as _i25;
import '../domain/usecase/chat/listen_to_messages_usecase.dart' as _i17;
import '../domain/usecase/chat/send_message_usecase.dart' as _i18;
import '../domain/usecase/chat_list/fetch_dialogs_usecase.dart' as _i26;
import '../domain/usecase/connect_status_listener/listen_connect_status_usecase.dart'
    as _i27;
import '../domain/usecase/error/listen_to_error_usecase.dart' as _i24;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.DatabaseProvider>(() => _i3.DatabaseProvider());
    gh.lazySingleton<_i4.SharedPreferencesGateway>(
        () => _i4.SharedPreferencesGateway());
    gh.lazySingleton<_i5.GrpcGateway>(() => _i5.GrpcGateway());
    gh.lazySingleton<_i6.AuthService>(() => _i7.AuthServiceImpl(
          gh<_i5.GrpcGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i8.LoginUseCase>(
        () => _i8.LoginImplUseCase(gh<_i6.AuthService>()));
    gh.lazySingleton<_i9.ChannelStatusListener>(
        () => _i9.ChannelStatusListener(gh<_i5.GrpcGateway>()));
    gh.lazySingleton<_i10.ConnectListenerGateway>(
        () => _i10.ConnectListenerGateway(
              gh<_i3.DatabaseProvider>(),
              gh<_i5.GrpcGateway>(),
            ));
    gh.lazySingleton<_i11.LogoutUseCase>(
        () => _i11.LogoutImplUseCase(gh<_i6.AuthService>()));
    gh.lazySingleton<_i12.ChatService>(() => _i13.ChatServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i10.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i14.ChatListService>(() => _i15.ChatListServiceImpl(
          gh<_i10.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i16.RegisterDeviceUseCase>(
        () => _i16.RegisterDeviceImplUseCase(gh<_i6.AuthService>()));
    gh.lazySingleton<_i17.ListenToMessagesUsecase>(
        () => _i17.ListenToMessagesImplUseCase(gh<_i12.ChatService>()));
    gh.lazySingleton<_i18.SendDialogMessageUseCase>(
        () => _i18.SendDialogMessageImplUseCase(gh<_i12.ChatService>()));
    gh.lazySingleton<_i19.FetchMessageUpdatesUseCase>(
        () => _i19.FetchMessageUpdatesImplUseCase(gh<_i12.ChatService>()));
    gh.lazySingleton<_i20.ErrorService>(
        () => _i21.ErrorServiceImpl(gh<_i10.ConnectListenerGateway>()));
    gh.lazySingleton<_i22.ConnectStatusListenerService>(() =>
        _i23.ConnectStatusListenerServiceImpl(
            gh<_i10.ConnectListenerGateway>()));
    gh.lazySingleton<_i24.ListenToErrorUseCase>(
        () => _i24.ListenToErrorImplUseCase(gh<_i20.ErrorService>()));
    gh.lazySingleton<_i25.FetchMessagesUseCase>(
        () => _i25.FetchMessagesImplUseCase(gh<_i12.ChatService>()));
    gh.lazySingleton<_i26.FetchDialogsUseCase>(
        () => _i26.FetchDialogsImplUseCase(gh<_i14.ChatListService>()));
    gh.lazySingleton<_i27.ListenConnectStatusUseCase>(() =>
        _i27.ListenConnectStatusImplUseCase(
            gh<_i22.ConnectStatusListenerService>()));
    return this;
  }
}
