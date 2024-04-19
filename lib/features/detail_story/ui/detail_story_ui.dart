// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/detail_story/cubit/detail_story_cubit.dart';
import 'package:story_app/widget/maps_widget.dart';
import 'package:story_app/utils/snackbar.dart';
import 'package:story_app/widget/appbar.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/loading.dart';
import 'package:story_app/widget/offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../cubit/detail_story_state.dart';

class DetailStoryUi extends StatefulWidget {
  String id;
  DetailStoryUi({super.key, required this.id});

  @override
  State<DetailStoryUi> createState() => _DetailStoryUiState();
}

class _DetailStoryUiState extends State<DetailStoryUi> {
  DetailStoryCubit? cubit;
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return BlocProvider<DetailStoryCubit>(
      create: (context) => DetailStoryCubit(
        ApiService(),
        widget.id,
        locale: locale,
      ),
      child: BlocConsumer<DetailStoryCubit, DetailStoryState>(
        builder: (context, state) {
          cubit = BlocProvider.of<DetailStoryCubit>(context);
          if (state is DetailStoryLoading) {
            return wrapScaffold(
              const LoadingAnimation(),
            );
          } else if (state is DetailStoryError) {
            return wrapScaffold(
              ErrorAnimation(
                onPressed: () {
                  cubit?.init(isLoad: true);
                },
                message: state.message,
              ),
            );
          } else if (state is DetailStoryOffline) {
            return wrapScaffold(
              OfflineAnimation(
                onPressed: () {
                  cubit?.init(isLoad: true);
                },
              ),
            );
          } else if (state is DetailStorySuccess) {
            var data = state.dataStory.story;
            LatLng? location = data?.lat != null && data?.lon != null
                ? LatLng(data?.lat ?? 0, data?.lon ?? 0)
                : null;
            return CustomAppBar(
              titleIsCenter: false,
              tag: data?.photoUrl ?? '',
              titleAppBar: locale!.detailStory,
              urlImage: data?.photoUrl ?? '',
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        data?.name ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        locale.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ReadMoreText(
                        data?.description ?? '-',
                        trimMode: TrimMode.Line,
                        trimLines: 4,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (location != null)
                        Text(
                          locale.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (location != null)
                        const SizedBox(
                          height: 5,
                        ),
                      if (location != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MapsScreen(
                            location: location,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
        listener: (context, state) {
          if (state is DetailStoryMessage) {
            showShortSnackBar(context, state.message);
          }
        },
      ),
    );
  }

  wrapScaffold(Widget child) {
    return Scaffold(
      body: child,
    );
  }
}
