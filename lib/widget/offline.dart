// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OfflineAnimation extends StatelessWidget {
  Function()? onPressed;
  OfflineAnimation({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/no_internet_animation.json',
        ),
        const Text('This internet is offline !!!'),
        TextButton(
          onPressed: onPressed,
          child: const Text(
            'Try Again',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
