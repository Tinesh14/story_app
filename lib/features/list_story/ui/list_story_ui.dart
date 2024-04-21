import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/data/model/story.dart';
import 'package:story_app/features/list_story/cubit/list_story_cubit.dart';
import 'package:story_app/features/list_story/cubit/list_story_state.dart';
import 'package:story_app/widget/card_story.dart';
import 'package:story_app/widget/empty.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/loading.dart';
import 'package:story_app/widget/offline.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListStoryUi extends StatefulWidget {
  final Function(String?) onTapped;
  final Function() onLogout;
  final Function(Function) onAddStory;
  const ListStoryUi({
    super.key,
    required this.onTapped,
    required this.onLogout,
    required this.onAddStory,
  });

  @override
  State<ListStoryUi> createState() => _ListStoryUiState();
}

class _ListStoryUiState extends State<ListStoryUi> {
  ListStoryCubit? bloc;
  final ScrollController scrollController = ScrollController();

  late List<Story> _stories;
  bool isLastPage = false;
  @override
  void initState() {
    _stories = [];
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (!isLastPage) Future(() async => await bloc?.fetchData());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale!.story,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<ListStoryCubit>(
          create: (context) => ListStoryCubit(
            ApiService(),
            locale: locale,
          ),
          child: BlocConsumer<ListStoryCubit, ListStoryState>(
            builder: (context, state) {
              bloc = BlocProvider.of<ListStoryCubit>(context);
              if (state is ListStoryLoading) {
                return const LoadingAnimation();
              } else if (state is ListStoryEmpty) {
                return const EmptyAnimation();
              } else if (state is ListStoryError) {
                return ErrorAnimation(
                  onPressed: () {
                    bloc?.init(isLoad: true);
                  },
                  message: state.message,
                );
              } else if (state is ListStoryOffline) {
                return OfflineAnimation(
                  onPressed: () {
                    bloc?.init(isLoad: true);
                  },
                );
              } else if (state is ListStorySuccess) {
                _stories = state.dataStories;
                isLastPage = state.isLastPage ?? false;
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      ListView.builder(
                        key: const Key('successKey'),
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _stories.length,
                        itemBuilder: (context, index) {
                          var item = _stories[index];
                          return InkWell(
                            onTap: () {
                              widget.onTapped(item.id);
                            },
                            child: CardStory(
                              imageUrl: item.photoUrl ?? '',
                              title: item.name ?? '',
                              description: item.description ?? '',
                            ),
                          );
                        },
                      ),
                      if (state.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (state.error) Center(child: errorDialog(size: 15))
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            listener: (context, state) {},
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        overlayOpacity: 0.5,
        animatedIcon: AnimatedIcons.menu_close,
        childMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        animatedIconTheme: const IconThemeData(size: 22.0),
        spacing: 20,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.logout),
            label: locale.logOut,
            onTap: () {
              widget.onLogout();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: locale.addStory,
            onTap: () {
              widget.onAddStory(
                () => bloc?.init(isLoad: true),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget errorDialog({required double size}) {
    return SizedBox(
      height: 180,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'An error occurred when fetching the stories.',
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              if (!isLastPage) await bloc?.fetchData();
            },
            child: const Text(
              "Retry",
              style: TextStyle(fontSize: 20, color: Colors.purpleAccent),
            ),
          ),
        ],
      ),
    );
  }
}
