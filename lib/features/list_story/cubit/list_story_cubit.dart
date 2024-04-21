import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/story.dart';
import 'package:story_app/features/list_story/cubit/list_story_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListStoryCubit extends Cubit<ListStoryState> {
  AppLocalizations? locale;
  final ApiService apiService;
  late ListStorySuccess listStorySuccess;
  int _pageNumber = 1;
  List<Story> dataStories = [];
  final int _numberOfPostsPerRequest = 10;
  bool isFetch = false;

  ListStoryCubit(this.apiService, {this.locale}) : super(ListStoryLoading()) {
    init();
  }

  init({bool isLoad = false}) async {
    try {
      if (isLoad) emit(ListStoryLoading());
      var response = await apiService.getAllStories(
          page: 0, size: _numberOfPostsPerRequest);
      if (response.listStory?.isNotEmpty ?? false) {
        dataStories.addAll(response.listStory ?? []);
        listStorySuccess = ListStorySuccess(dataStories: dataStories);
        emit(listStorySuccess);
      } else {
        emit(ListStoryEmpty());
      }
    } catch (e) {
      if (e is SocketException) {
        emit(ListStoryOffline());
      } else {
        emit(ListStoryError(message: locale!.sww));
      }
    }
  }

  Future<void> fetchData() async {
    if (!isFetch) {
      try {
        isFetch = true;
        listStorySuccess =
            listStorySuccess.copyWith(loading: true, pageNumber: _pageNumber);
        emit(listStorySuccess);
        var response = await apiService.getAllStories(
            page: _pageNumber, size: _numberOfPostsPerRequest);
        List<Story> storyList = response.listStory ?? [];
        dataStories.addAll(response.listStory ?? []);
        if (storyList.isNotEmpty) {
          _pageNumber = _pageNumber + 1;
          listStorySuccess = listStorySuccess.copyWith(
            dataStories: dataStories,
            loading: false,
            isLastPage: storyList.length < _numberOfPostsPerRequest,
            pageNumber: _pageNumber,
          );
          emit(listStorySuccess);
        }
      } catch (e) {
        listStorySuccess =
            listStorySuccess.copyWith(loading: false, error: true);
        emit(listStorySuccess);
      }
      isFetch = false;
    }
  }
}
