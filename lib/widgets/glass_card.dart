import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Carte avec effet "glassmorphism" : fond semi-transparent + backdrop blur
/// + bordure subtile. Fonctionne sur fond dark ou light, s'adapte au theme.
///
/// Exemple :
///   GlassCard(
///     padding: const EdgeInsets.all(20),
///     child: Column(children: [...]),
///   )
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blur = 12,
    this.tint,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = tint ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.lightBorder;

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? base : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}
