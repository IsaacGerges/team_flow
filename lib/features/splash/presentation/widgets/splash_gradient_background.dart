import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SplashGradientBackground extends StatelessWidget {
  const SplashGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBluePure,
            AppColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }
}
