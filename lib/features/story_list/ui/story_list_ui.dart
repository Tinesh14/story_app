import 'package:flutter/material.dart';

class StoryListUi extends StatefulWidget {
  final Function(String) onTapped;
  final Function() onLogout;
  const StoryListUi({
    super.key,
    required this.onTapped,
    required this.onLogout,
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
          'Story List',
        ),
      ),
      body: const Center(
        child: Text(
          'INI PAGE STORY LIST !!!',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onLogout();
        },
        tooltip: 'Logout',
        icon: const Icon(
          Icons.logout,
        ),
        label: const Text('LogOut'),
      ),
    );
  }
}
