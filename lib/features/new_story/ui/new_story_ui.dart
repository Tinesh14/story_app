// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/new_story/cubit/new_story_cubit.dart';
import 'package:story_app/features/new_story/cubit/new_story_state.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/loading.dart';
import 'package:story_app/widget/offline.dart';

class NewStoryUi extends StatefulWidget {
  Function() onRefreshListStory;
  NewStoryUi({
    super.key,
    required this.onRefreshListStory,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Story',
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
                                size: 350,
                              ),
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _onGalleryView(),
                            child: const Text("Gallery"),
                          ),
                          ElevatedButton(
                            onPressed: () => _onCameraView(),
                            child: const Text("Camera"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Description",
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your description.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if (formKey.currentState?.validate() ?? false) {
                                await upload();
                              }
                            },
                            child: const Text("Upload"),
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
                  await upload(loadAgain: true);
                },
              );
            } else if (state is NewStoryError) {
              return ErrorAnimation(
                onPressed: () async {
                  await upload(loadAgain: true);
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

  upload({bool loadAgain = false}) async {
    if (imageFile != null) {
      var fileName = imageFile?.name;
      var bytes = await imageFile?.readAsBytes();
      var compress = await cubit?.compressImage(bytes!);
      if (loadAgain) {
        cubit?.loadAgain(descriptionController.text, compress!, fileName ?? '');
      } else {
        cubit?.uploadStory(
            descriptionController.text, compress!, fileName ?? '');
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
