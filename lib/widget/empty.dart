import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyAnimation extends StatelessWidget {
  const EmptyAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/no_data_animation.json',
        ),
        const Text('No Data Available !!!'),
      ],
    );
  }
}
