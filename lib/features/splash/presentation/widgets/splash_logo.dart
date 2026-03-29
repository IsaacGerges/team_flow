import '../../../../core/constants/app_assets.dart';
import 'package:flutter/material.dart';

/// A branded logo widget with an entrance scale + fade animation.
///
/// By default it renders with white tones suitable for a dark/gradient
/// background (splash screen). Pass [backgroundColor], [borderColor], and
/// [iconColor] to adapt it to light backgrounds such as the auth screens.
class SplashLogo extends StatefulWidget {
  const SplashLogo({
    super.key,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  /// Container fill color. Defaults to `white @ 10%` for dark backgrounds.
  final Color? backgroundColor;

  /// Container border color. Defaults to `white @ 20%` for dark backgrounds.
  final Color? borderColor;

  /// Icon color. Defaults to white. (Note: Only used if image fails or for tinting if applicable)
  final Color? iconColor;

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          AppAssets.logo,
          width: 125,
          height: 125,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.image_not_supported_outlined,
            color: widget.iconColor ?? Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}
