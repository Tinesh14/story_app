// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorAnimation extends StatelessWidget {
  Function()? onPressed;
  String? message;
  ErrorAnimation({super.key, this.onPressed, this.message});

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/error_animation.json',
        ),
        Text('${locale!.error}: $message'),
        TextButton(
          onPressed: onPressed,
          child: Text(
            locale.tryAgain,
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
