import 'package:flutter/material.dart';

/// Palette centralisée Ndako — Dark Premium + Light Modern.
///
/// Convention :
/// - `bg*`     : fonds (background, surface, élévé)
/// - `text*`   : couleurs de texte
/// - `accent*` : accents fonctionnels (primary, secondary, tertiary)
/// - `device*` : couleurs spécifiques par type de module
/// - `state*`  : success / warning / danger
class AppColors {
  AppColors._();

  // ─────────────────────────── DARK PREMIUM ──────────────────────────────
  // Inspiration : Tuya Smart, Mi Home, concepts Dribbble smart-home dark.
  static const Color darkBg = Color(0xFF0A0E1A);          // noir bleuté profond
  static const Color darkSurface = Color(0xFF131927);     // cartes
  static const Color darkSurfaceElevated = Color(0xFF1B2235); // cartes élevées
  static const Color darkBorder = Color(0xFF253047);      // bordures subtiles
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF475569);

  // ─────────────────────────── LIGHT MODERN ──────────────────────────────
  static const Color lightBg = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEEF2F8);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextDisabled = Color(0xFFCBD5E1);

  // ─────────────────────────── ACCENTS ───────────────────────────────────
  // Couleur principale de l'app — bleu électrique premium.
  static const Color accentPrimary = Color(0xFF4F8FFF);
  static const Color accentPrimaryDeep = Color(0xFF2563EB);
  static const Color accentSecondary = Color(0xFFB47AEA); // violet
  static const Color accentTertiary = Color(0xFFFFB547);  // ambre

  // Gradients premium pour boutons / cartes "active".
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4F8FFF), Color(0xFF7B5BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFB547), Color(0xFFFF7A59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF4F8FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────── DEVICE COLORS ─────────────────────────────
  // Une couleur signature par type de module — utilisée dans les cartes,
  // icônes, gradients d'accent quand le module est ON.
  static const Color deviceClim = Color(0xFF4FC3F7);          // cyan glacé
  static const Color deviceClimSoft = Color(0xFF2C7DA0);
  static const Color deviceEclairage = Color(0xFFFFC857);     // ambre chaud
  static const Color deviceEclairageSoft = Color(0xFFB8860B);
  static const Color deviceGaz = Color(0xFFFF6B6B);           // corail
  static const Color deviceGazSoft = Color(0xFFC1352F);
  static const Color deviceCompteur = Color(0xFF69F0AE);      // vert électrique
  static const Color deviceCompteurSoft = Color(0xFF2E8B57);
  static const Color deviceAssistant = Color(0xFFB47AEA);     // violet
  static const Color deviceAssistantSoft = Color(0xFF6B46C1);
  static const Color devicePrise = Color(0xFF94A3B8);         // gris neutre

  /// Couleur signature d'un type de module Django.
  /// `type` ∈ { clim, eclairage, gaz, compteur, assistant_vocal, prise, ... }
  static Color forDeviceType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'clim':
      case 'climatisation':
        return deviceClim;
      case 'eclairage':
      case 'lampe':
      case 'lumiere':
      case 'lumière':
        return deviceEclairage;
      case 'gaz':
        return deviceGaz;
      case 'compteur':
        return deviceCompteur;
      case 'assistant_vocal':
      case 'assistant':
      case 'vocal':
        return deviceAssistant;
      case 'prise':
        return devicePrise;
      default:
        return accentPrimary;
    }
  }

  /// Gradient cohérent avec la couleur signature d'un device.
  static LinearGradient gradientForDeviceType(String? type) {
    final c = forDeviceType(type);
    return LinearGradient(
      colors: [c, Color.lerp(c, Colors.black, 0.4)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ─────────────────────────── STATES ────────────────────────────────────
  static const Color stateSuccess = Color(0xFF22C55E);
  static const Color stateWarning = Color(0xFFF59E0B);
  static const Color stateDanger = Color(0xFFEF4444);
  static const Color stateInfo = Color(0xFF3B82F6);
}
