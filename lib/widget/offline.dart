// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineAnimation extends StatelessWidget {
  Function()? onPressed;
  OfflineAnimation({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/no_internet_animation.json',
        ),
        Text(locale!.offline),
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
