// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/gateway/channel_status_listener.dart' as _i20;
import '../data/gateway/connect_listener_gateway.dart' as _i7;
import '../data/gateway/grpc_gateway.dart' as _i5;
import '../data/gateway/image_compress_gateway.dart' as _i6;
import '../data/gateway/shared_preferences_gateway.dart' as _i4;
import '../data/service_impl/auth_service_impl.dart' as _i16;
import '../data/service_impl/chat_list_service_impl.dart' as _i23;
import '../data/service_impl/chat_service_impl.dart' as _i18;
import '../data/service_impl/connect_status_listener_service_impl.dart' as _i11;
import '../data/service_impl/error_service_impl.dart' as _i13;
import '../data/service_impl/portal_service_impl.dart' as _i9;
import '../database/database.dart' as _i3;
import '../domain/services/auth_service.dart' as _i15;
import '../domain/services/chat_list_service.dart' as _i22;
import '../domain/services/chat_service.dart' as _i17;
import '../domain/services/connect_status_listener_service.dart' as _i10;
import '../domain/services/error_service.dart' as _i12;
import '../domain/services/portal_service.dart' as _i8;
import '../domain/usecase/auth/login_usecase.dart' as _i26;
import '../domain/usecase/auth/logout_usecase.dart' as _i29;
import '../domain/usecase/auth/register_device_usecase.dart' as _i33;
import '../domain/usecase/chat/enter_chat_usecase.dart' as _i27;
import '../domain/usecase/chat/exit_chat_usecase.dart' as _i30;
import '../domain/usecase/chat/fetch_message_updates.dart' as _i31;
import '../domain/usecase/chat/fetch_messages.dart' as _i32;
import '../domain/usecase/chat/listen_to_messages_usecase.dart' as _i25;
import '../domain/usecase/chat/send_message_usecase.dart' as _i24;
import '../domain/usecase/chat_list/fetch_dialogs_usecase.dart' as _i28;
import '../domain/usecase/connect_status_listener/listen_connect_status_usecase.dart'
    as _i14;
import '../domain/usecase/error/listen_to_error_usecase.dart' as _i21;
import '../domain/usecase/portal/exit_portal.dart' as _i19;

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
    gh.lazySingleton<_i6.ImageCompressGateway>(
        () => _i6.ImageCompressGateway());
    gh.lazySingleton<_i7.ConnectListenerGateway>(
        () => _i7.ConnectListenerGateway(
              gh<_i3.DatabaseProvider>(),
              gh<_i5.GrpcGateway>(),
            ));
    gh.lazySingleton<_i8.PortalService>(
        () => _i9.PortalServiceImpl(gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i10.ConnectStatusListenerService>(() =>
        _i11.ConnectStatusListenerServiceImpl(
            gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i12.ErrorService>(
        () => _i13.ErrorServiceImpl(gh<_i7.ConnectListenerGateway>()));
    gh.lazySingleton<_i14.ListenConnectStatusUseCase>(() =>
        _i14.ListenConnectStatusImplUseCase(
            gh<_i10.ConnectStatusListenerService>()));
    gh.lazySingleton<_i15.AuthService>(() => _i16.AuthServiceImpl(
          gh<_i3.DatabaseProvider>(),
          gh<_i5.GrpcGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i17.ChatService>(() => _i18.ChatServiceImpl(
          gh<_i5.GrpcGateway>(),
          gh<_i7.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i19.ExitPortalUseCase>(
        () => _i19.ExitPortalImplUseCase(gh<_i8.PortalService>()));
    gh.lazySingleton<_i20.ChannelStatusListener>(
        () => _i20.ChannelStatusListener(gh<_i5.GrpcGateway>()));
    gh.lazySingleton<_i21.ListenToErrorUseCase>(
        () => _i21.ListenToErrorImplUseCase(gh<_i12.ErrorService>()));
    gh.lazySingleton<_i22.ChatListService>(() => _i23.ChatListServiceImpl(
          gh<_i7.ConnectListenerGateway>(),
          gh<_i4.SharedPreferencesGateway>(),
        ));
    gh.lazySingleton<_i24.SendMessageUseCase>(
        () => _i24.SendMessageImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i25.ListenToMessagesUsecase>(
        () => _i25.ListenToMessagesImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i26.LoginUseCase>(
        () => _i26.LoginImplUseCase(gh<_i15.AuthService>()));
    gh.lazySingleton<_i27.EnterChatUsecase>(
        () => _i27.EnterChatImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i28.FetchDialogsUseCase>(
        () => _i28.FetchDialogsImplUseCase(gh<_i22.ChatListService>()));
    gh.lazySingleton<_i29.LogoutUseCase>(
        () => _i29.LogoutImplUseCase(gh<_i15.AuthService>()));
    gh.lazySingleton<_i30.ExitChatUsecase>(
        () => _i30.ExitChatImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i31.FetchUpdatesUseCase>(
        () => _i31.FetchUpdatesImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i32.FetchMessagesUseCase>(
        () => _i32.FetchMessagesImplUseCase(gh<_i17.ChatService>()));
    gh.lazySingleton<_i33.RegisterDeviceUseCase>(
        () => _i33.RegisterDeviceImplUseCase(gh<_i15.AuthService>()));
    return this;
  }
}
