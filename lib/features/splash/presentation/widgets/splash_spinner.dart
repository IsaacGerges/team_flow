import 'package:team_flow/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SplashSpinner extends StatefulWidget {
  const SplashSpinner({super.key});

  @override
  State<SplashSpinner> createState() => _SplashSpinnerState();
}

class _SplashSpinnerState extends State<SplashSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: 45,
        height: 45,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
          backgroundColor: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
