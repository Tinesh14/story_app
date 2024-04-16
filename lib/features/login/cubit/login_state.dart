import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginError extends LoginState {
  final String? message;
  const LoginError({this.message});
}

class LoginMessage extends LoginState {
  final String message;
  const LoginMessage({required this.message});
}

class LoginSuccess extends LoginState {}

class LoginOffline extends LoginState {}
