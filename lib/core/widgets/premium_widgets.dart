import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A high-end Glassmorphic card with enhanced visibility controls.
class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;
  final Border? border;
  final Color? color;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 28.0,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.padding,
    this.margin,
    this.shadows,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppColors.glassShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A container that applies a pure glass shadow without the blur filter,
/// useful for layering or simple cards.
class GlassShadowContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const GlassShadowContainer({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppColors.glassShadow(),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

/// Soft green-wash background — replaces old teal orbs with premium green radials.
class GreenWashBackground extends StatelessWidget {
  const GreenWashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full background gradient
        Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: PremiumOrb(color: AppColors.primary.withValues(alpha: 0.12), size: 320),
        ),
        Positioned(
          bottom: 100,
          left: -60,
          child: PremiumOrb(color: AppColors.secondary.withValues(alpha: 0.08), size: 260),
        ),
        Positioned(
          top: 350,
          right: -40,
          child: PremiumOrb(color: AppColors.primaryDark.withValues(alpha: 0.05), size: 180),
        ),
      ],
    );
  }
}

/// Keep old name as alias for backward compatibility
class PremiumBackgroundBlobs extends StatelessWidget {
  const PremiumBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return const GreenWashBackground();
  }
}

class PremiumOrb extends StatelessWidget {
  final Color color;
  final double size;
  const PremiumOrb({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

/// Updated GlassAppBar — uses green-tinted styling.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PremiumGlassCard(
        borderRadius: 20,
        opacity: 0.15,
        blur: 12,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
        child: AppBar(
          title: Text(title, style: AppTextStyles.heading3()),
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

/// A wrapper that adds a subtle scale animation on tap for a premium feel.
class AnimatedInteractiveContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AnimatedInteractiveContainer({super.key, required this.child, required this.onTap});

  @override
  State<AnimatedInteractiveContainer> createState() => _AnimatedInteractiveContainerState();
}

class _AnimatedInteractiveContainerState extends State<AnimatedInteractiveContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
