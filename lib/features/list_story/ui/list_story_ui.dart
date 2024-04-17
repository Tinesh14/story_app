import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:story_app/data/api/api_service.dart';
import 'package:story_app/features/list_story/cubit/list_story_cubit.dart';
import 'package:story_app/features/list_story/cubit/list_story_state.dart';
import 'package:story_app/widget/card_story.dart';
import 'package:story_app/widget/empty.dart';
import 'package:story_app/widget/error.dart';
import 'package:story_app/widget/loading.dart';
import 'package:story_app/widget/offline.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<ListStoryCubit>(
          create: (context) => ListStoryCubit(
            ApiService(),
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
                var dataStories = state.dataStories;
                return ListView.builder(
                  key: const Key('successKey'),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dataStories.length,
                  itemBuilder: (context, index) {
                    var item = dataStories[index];
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
            label: 'Log Out',
            onTap: () {
              widget.onLogout();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Story',
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
}
