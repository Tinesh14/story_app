import 'package:story_app/data/model/story.dart';

abstract class ListStoryState {}

class ListStoryLoading extends ListStoryState {}

class ListStoryError extends ListStoryState {
  final String? message;
  ListStoryError({this.message});
}

class ListStorySuccess extends ListStoryState {
  final List<Story> dataStories;
  final bool loading;
  final bool error;
  int? pageNumber;
  bool? isLastPage;
  ListStorySuccess({
    required this.dataStories,
    this.loading = false,
    this.error = false,
    this.pageNumber,
    this.isLastPage,
  });

  ListStorySuccess copyWith({
    List<Story>? dataStories,
    bool? loading,
    bool? error,
    int? pageNumber,
    bool? isLastPage,
  }) {
    return ListStorySuccess(
      dataStories: dataStories ?? this.dataStories,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class ListStoryEmpty extends ListStoryState {}

class ListStoryOffline extends ListStoryState {}
