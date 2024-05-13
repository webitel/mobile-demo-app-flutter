part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final AuthStatus authStatus;
  final Object error;
  final Client? client;

  const AuthState({
    required this.authStatus,
    required this.error,
    required this.client,
  });

  static AuthState initial() {
    return const AuthState(
      client: null,
      authStatus: AuthStatus.initial,
      error: '',
    );
  }

  @override
  List<Object?> get props => [
        authStatus,
        client,
        error,
      ];

  AuthState copyWith({
    AuthStatus? authStatus,
    Object? error,
    Client? client,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      error: error ?? this.error,
      client: client ?? this.client,
    );
  }
}
