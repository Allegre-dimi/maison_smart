import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Icône Material standardisée par type de module Django.
IconData iconForDeviceType(String? type) {
  switch ((type ?? '').toLowerCase()) {
    case 'clim':
    case 'climatisation':
      return Icons.ac_unit_rounded;
    case 'eclairage':
    case 'lampe':
    case 'lumiere':
    case 'lumière':
      return Icons.lightbulb_rounded;
    case 'gaz':
      return Icons.local_fire_department_rounded;
    case 'compteur':
      return Icons.bolt_rounded;
    case 'assistant_vocal':
    case 'assistant':
    case 'vocal':
      return Icons.mic_rounded;
    case 'prise':
      return Icons.power_rounded;
    default:
      return Icons.devices_other_rounded;
  }
}

/// Badge icône premium pour un module — disque coloré avec icône blanche,
/// halo glow quand `active`. Cohérent avec [AppColors.forDeviceType].
class DeviceIconBadge extends StatelessWidget {
  final String? type;
  final bool active;
  final double size;

  const DeviceIconBadge({
    super.key,
    required this.type,
    this.active = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forDeviceType(type);
    final icon = iconForDeviceType(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: active
            ? LinearGradient(
                colors: [color, Color.lerp(color, Colors.black, 0.35)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: active ? null : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: active ? Colors.white : color,
      ),
    );
  }
}
