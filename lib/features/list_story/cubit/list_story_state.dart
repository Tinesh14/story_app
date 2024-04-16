import 'package:equatable/equatable.dart';
import 'package:story_app/data/model/story.dart';

abstract class ListStoryState extends Equatable {
  const ListStoryState();
  @override
  List<Object> get props => [];
}

class ListStoryLoading extends ListStoryState {}

class ListStoryError extends ListStoryState {
  final String? message;
  const ListStoryError({this.message});
}

class ListStorySuccess extends ListStoryState {
  final List<Story> dataStories;
  const ListStorySuccess(this.dataStories);
}

class ListStoryEmpty extends ListStoryState {}

class ListStoryOffline extends ListStoryState {}
