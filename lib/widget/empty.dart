import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyAnimation extends StatelessWidget {
  const EmptyAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/no_data_animation.json',
        ),
        Text(locale!.noData),
      ],
    );
  }
}
