// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorAnimation extends StatelessWidget {
  Function()? onPressed;
  String? message;
  ErrorAnimation({super.key, this.onPressed, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/error_animation.json',
        ),
        Text('Error: $message'),
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
