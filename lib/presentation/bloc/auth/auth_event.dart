part of 'auth_bloc.dart';

sealed class AuthEvent {}

class LoginEvent extends AuthEvent {}

class InitClientEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class RegisterDevice extends AuthEvent {}
