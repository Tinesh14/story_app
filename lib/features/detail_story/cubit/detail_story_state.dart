import 'package:equatable/equatable.dart';
import 'package:story_app/data/model/story.dart';

abstract class DetailStoryState extends Equatable {
  const DetailStoryState();
  @override
  List<Object> get props => [];
}

class DetailStoryLoading extends DetailStoryState {}

class DetailStoryError extends DetailStoryState {
  final String? message;
  const DetailStoryError({this.message});
}

class DetailStoryMessage extends DetailStoryState {
  final String message;
  const DetailStoryMessage({required this.message});
}

class DetailStorySuccess extends DetailStoryState {
  final DetailStory dataStory;
  const DetailStorySuccess(this.dataStory);
}

class DetailStoryEmpty extends DetailStoryState {}

class DetailStoryOffline extends DetailStoryState {}
