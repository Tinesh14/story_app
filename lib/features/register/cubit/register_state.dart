import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterError extends RegisterState {
  final String? message;
  const RegisterError({this.message});
}

class RegisterMessage extends RegisterState {
  final String message;
  const RegisterMessage({required this.message});
}

class RegisterSuccess extends RegisterState {}

class RegisterOffline extends RegisterState {}
