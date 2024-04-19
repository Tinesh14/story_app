import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:image/image.dart';
import 'package:story_app/features/new_story/cubit/new_story_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewStoryCubit extends Cubit<NewStoryState> {
  AppLocalizations? locale;
  final ApiService apiService;
  NewStoryCubit(this.apiService, {this.locale}) : super(NewStoryInitial());

  Future uploadStory(String description, List<int> bytes, String fileName,
      {double? lat, double? lon}) async {
    try {
      emit(NewStoryLoading());
      var response = await apiService.addNewStory(description, bytes, fileName,
          lat: lat, lon: lon);
      if (!(response['error'] ?? false)) {
        emit(NewStorySuccess());
      } else {
        emit(NewStoryMessage(
            message: response['message'] ?? locale!.failedUploadStory));
      }
    } catch (e) {
      if (e is SocketException) {
        emit(NewStoryOffline());
      } else {
        emit(NewStoryError(message: locale!.sww));
      }
    }
  }

  Future<LatLng?> requestPermission() async {
    var lastState = state;
    emit(NewStoryLoading());
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;
    LatLng? latLng;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        emit(const NewStoryMessage(
            message: "Location services is not available"));
        emit(lastState);
        return null;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        emit(const NewStoryMessage(
            message:
                "Location permission is denied, Please go to setting and turn on location permission manually"));
        emit(lastState);
        return null;
      }
    }
    locationData = await location.getLocation();
    latLng = LatLng(locationData.latitude!, locationData.longitude!);
    emit(lastState);
    return latLng;
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

  loadAgain(String description, List<int> bytes, String fileName,
      {double? lat, double? lon}) async {
    emit(NewStoryInitial());
    await uploadStory(description, bytes, fileName, lat: lat, lon: lon);
  }
}
