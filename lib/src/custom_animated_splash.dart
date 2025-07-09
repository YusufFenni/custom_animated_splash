import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Container(
        color: const Color(0xFFFF0000), // Splash color
        alignment: Alignment.center,
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset('assets/splash.json'), // Splash animation
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}