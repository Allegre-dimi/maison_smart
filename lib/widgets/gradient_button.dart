import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton premium avec gradient + ombre lumineuse douce + état "loading".
///
/// Exemple :
///   GradientButton(
///     label: 'Se connecter',
///     icon: Icons.login_rounded,
///     onPressed: _login,
///     loading: _busy,
///   )
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final Gradient gradient;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.gradient = AppColors.accentGradient,
    this.height = 54,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glow = (gradient is LinearGradient)
        ? (gradient as LinearGradient).colors.first
        : AppColors.accentPrimary;

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      width: fullWidth ? double.infinity : null,
      padding: padding,
      decoration: BoxDecoration(
        gradient: disabled
            ? LinearGradient(
                colors: [
                  glow.withValues(alpha: 0.35),
                  glow.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: glow.withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 19),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return button;
  }
}
