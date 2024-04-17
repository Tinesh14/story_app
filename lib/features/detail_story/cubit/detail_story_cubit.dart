import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/features/detail_story/cubit/detail_story_state.dart';

import '../../../data/api/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailStoryCubit extends Cubit<DetailStoryState> {
  AppLocalizations? locale;
  final ApiService apiService;
  final String id;
  DetailStoryCubit(this.apiService, this.id, {this.locale})
      : super(DetailStoryLoading()) {
    init();
  }
  init({bool isLoad = false}) async {
    try {
      if (isLoad) emit(DetailStoryLoading());
      var response = await apiService.detailStory(id);
      emit(DetailStorySuccess(response));
    } catch (e) {
      if (e is SocketException) {
        emit(DetailStoryOffline());
      } else {
        emit(DetailStoryError(message: locale!.sww));
      }
    }
  }
}
