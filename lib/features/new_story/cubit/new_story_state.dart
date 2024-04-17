import 'package:equatable/equatable.dart';

abstract class NewStoryState extends Equatable {
  const NewStoryState();
  @override
  List<Object> get props => [];
}

class NewStoryInitial extends NewStoryState {}

class NewStoryLoading extends NewStoryState {}

class NewStoryError extends NewStoryState {
  final String? message;
  const NewStoryError({this.message});
}

class NewStoryMessage extends NewStoryState {
  final String message;
  const NewStoryMessage({required this.message});
}

class NewStorySuccess extends NewStoryState {}

class NewStoryOffline extends NewStoryState {}
