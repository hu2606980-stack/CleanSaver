import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_colors.dart';

/// A reusable container that provides a premium glassmorphic effect.
/// It applies a backdrop filter blur and subtle semi-transparent background.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final double blurAmount;
  final Border? border;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    this.backgroundColor,
    this.blurAmount = 10,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: AppColors.glassBorder, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
