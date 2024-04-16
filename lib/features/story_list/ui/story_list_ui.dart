import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class StoryListUi extends StatefulWidget {
  final Function(String) onTapped;
  final Function() onLogout;
  final Function() onAddStory;
  const StoryListUi({
    super.key,
    required this.onTapped,
    required this.onLogout,
    required this.onAddStory,
  });

  @override
  State<StoryListUi> createState() => _StoryListUiState();
}

class _StoryListUiState extends State<StoryListUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story',
        ),
      ),
      body: const Center(
        child: Text(
          'INI PAGE STORY LIST !!!',
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
              widget.onAddStory();
            },
          ),
        ],
      ),
      // FloatingActionButton.extended(
      //   onPressed: () {
      //     widget.onLogout();
      //   },
      //   tooltip: 'Logout',
      //   icon: const Icon(
      //     Icons.logout,
      //   ),
      //   label: const Text('LogOut'),
      // ),
    );
  }
}
