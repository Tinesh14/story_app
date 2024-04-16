import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/splash_screen_animation.json",
              fit: BoxFit.contain,
              repeat: false,
              onLoaded: (p0) {
                // _controller
                //   ..duration = p0.duration
                //   ..forward().whenComplete(
                //     () => Navigator.popAndPushNamed(
                //       context,
                //       PageRoutes.bottomNavigation,
                //     ),
                //   );
              },
            ),
            // Text(
            //   'Loading Splash...',
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}
