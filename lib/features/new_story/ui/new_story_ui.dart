import 'package:flutter/material.dart';

class NewStoryUi extends StatefulWidget {
  const NewStoryUi({super.key});

  @override
  State<NewStoryUi> createState() => _NewStoryUiState();
}

class _NewStoryUiState extends State<NewStoryUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Story',
        ),
      ),
      body: const Center(
        child: Text(
          'INI PAGE ADD STORY !!!',
        ),
      ),
    );
  }
}
