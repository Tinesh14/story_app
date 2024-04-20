// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/new_story/cubit/new_story_cubit.dart';
import 'package:story_app/features/new_story/cubit/new_story_state.dart';
import 'package:story_app/utils/flavor_config.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/loading.dart';
import 'package:story_app/widget/offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewStoryUi extends StatefulWidget {
  Function() onRefreshListStory;
  Function(LatLng) onPickerMap;
  Function(Function(geo.Placemark, LatLng)) onSetLocation;
  NewStoryUi({
    super.key,
    required this.onRefreshListStory,
    required this.onPickerMap,
    required this.onSetLocation,
  });

  @override
  State<NewStoryUi> createState() => _NewStoryUiState();
}

class _NewStoryUiState extends State<NewStoryUi> {
  String? imagePath;

  XFile? imageFile;
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  NewStoryCubit? cubit;
  geo.Placemark? selectedPlacemark;
  LatLng? selectedLatLng;
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale!.addStory,
        ),
      ),
      body: BlocProvider<NewStoryCubit>(
        create: (context) => NewStoryCubit(
          ApiService(),
        ),
        child: BlocConsumer<NewStoryCubit, NewStoryState>(
          buildWhen: (previous, current) =>
              current is! NewStorySuccess || current is! NewStoryMessage,
          builder: (context, state) {
            cubit = BlocProvider.of<NewStoryCubit>(context);
            if (state is NewStoryInitial) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      imagePath != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: _showImage(),
                            )
                          : const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image,
                                size: 300,
                              ),
                            ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _onGalleryView(),
                            child: Text(locale.gallery),
                          ),
                          ElevatedButton(
                            onPressed: () => _onCameraView(),
                            child: Text(locale.camera),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                hintText: locale.description,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return locale.validateDescription;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: selectedPlacemark != null
                                  ? TextEditingController(
                                      text:
                                          '${selectedPlacemark?.street}\n${selectedPlacemark?.locality}, ${selectedPlacemark?.postalCode}, ${selectedPlacemark?.country}')
                                  : null,
                              onTap: () async {
                                if (FlavorConfig.instance.flavor ==
                                    FlavorType.paid) {
                                  var latLng = await cubit?.requestPermission();
                                  if (latLng != null) {
                                    widget.onPickerMap(latLng);
                                    widget.onSetLocation((placemark, location) {
                                      setState(() {
                                        selectedPlacemark = placemark;
                                        selectedLatLng = location;
                                      });
                                    });
                                  }
                                } else {
                                  showShortSnackBar(
                                      context, "Fitur ini berbayar");
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              maxLines: selectedPlacemark != null ? 3 : 1,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                hintText: "Picker Location",
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (formKey.currentState?.validate() ?? false) {
                                await upload(
                                    lat: selectedLatLng?.latitude,
                                    lon: selectedLatLng?.longitude);
                              }
                            },
                            child: Text(locale.upload),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is NewStoryLoading) {
              return const LoadingAnimation();
            } else if (state is NewStoryOffline) {
              return OfflineAnimation(
                onPressed: () async {
                  await upload(
                      loadAgain: true,
                      lat: selectedLatLng?.latitude,
                      lon: selectedLatLng?.longitude);
                },
              );
            } else if (state is NewStoryError) {
              return ErrorAnimation(
                onPressed: () async {
                  await upload(
                      loadAgain: true,
                      lat: selectedLatLng?.latitude,
                      lon: selectedLatLng?.longitude);
                },
                message: state.message,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          listener: (context, state) {
            if (state is NewStorySuccess) {
              descriptionController.clear();
              imagePath = null;
              imageFile = null;
              widget.onRefreshListStory();
            } else if (state is NewStoryMessage) {
              showShortSnackBar(context, state.message);
            }
          },
        ),
      ),
    );
  }

  upload({bool loadAgain = false, double? lat, double? lon}) async {
    if (imageFile != null) {
      var fileName = imageFile?.name;
      var bytes = await imageFile?.readAsBytes();
      var compress = await cubit?.compressImage(bytes!);
      if (loadAgain) {
        cubit?.loadAgain(descriptionController.text, compress!, fileName ?? '',
            lat: lat, lon: lon);
      } else {
        cubit?.uploadStory(
            descriptionController.text, compress!, fileName ?? '',
            lat: lat, lon: lon);
      }
    }
  }

  Widget _showImage() {
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
            height: 350,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
            height: 350,
          );
  }

  _onCameraView() async {
    FocusScope.of(context).unfocus();
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }

  _onGalleryView() async {
    FocusScope.of(context).unfocus();
    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }
}
