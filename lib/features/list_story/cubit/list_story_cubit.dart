import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/list_story/cubit/list_story_state.dart';

class ListStoryCubit extends Cubit<ListStoryState> {
  final ApiService apiService;
  ListStoryCubit(this.apiService) : super(ListStoryLoading()) {
    init();
  }

  init({bool isLoad = false}) async {
    try {
      if (isLoad) emit(ListStoryLoading());
      var response = await apiService.getAllStories();
      if (response.listStory?.isNotEmpty ?? false) {
        emit(ListStorySuccess(response.listStory ?? []));
      } else {
        emit(ListStoryEmpty());
      }
    } catch (e) {
      if (e is SocketException) {
        emit(ListStoryOffline());
      } else {
        emit(const ListStoryError(message: 'Something Went Wrong !!!'));
      }
    }
  }
}
