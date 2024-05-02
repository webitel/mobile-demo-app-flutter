part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final AuthStatus authStatus;
  final Object error;

  const AuthState({required this.authStatus, required this.error});

  static AuthState initial() {
    return const AuthState(
      authStatus: AuthStatus.initial,
      error: '',
    );
  }

  @override
  List<Object?> get props => [authStatus];

  AuthState copyWith({
    AuthStatus? authStatus,
    Object? error,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      error: error ?? this.error,
    );
  }
}
