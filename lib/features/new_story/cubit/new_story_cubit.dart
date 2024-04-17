import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:image/image.dart';
import 'package:story_app/features/new_story/cubit/new_story_state.dart';

class NewStoryCubit extends Cubit<NewStoryState> {
  final ApiService apiService;
  NewStoryCubit(this.apiService) : super(NewStoryInitial());

  Future uploadStory(
      String description, List<int> bytes, String fileName) async {
    try {
      emit(NewStoryLoading());
      var response = await apiService.addNewStory(description, bytes, fileName);
      if (!(response['error'] ?? false)) {
        emit(NewStorySuccess());
      } else {
        emit(NewStoryMessage(
            message: response['message'] ?? 'Gagal Upload Story !!!'));
      }
    } catch (e) {
      if (e is SocketException) {
        emit(NewStoryOffline());
      } else {
        emit(const NewStoryError(message: 'Something Went Wrong !!!'));
      }
    }
  }

  Future<List<int>> compressImage(Uint8List bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final Image image = decodeImage(bytes)!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];

    do {
      ///
      compressQuality -= 10;

      newByte = encodeJpg(
        image,
        quality: compressQuality,
      );

      length = newByte.length;
    } while (length > 1000000);

    return newByte;
  }

  loadAgain(String description, List<int> bytes, String fileName) async {
    emit(NewStoryInitial());
    await uploadStory(description, bytes, fileName);
  }
}
