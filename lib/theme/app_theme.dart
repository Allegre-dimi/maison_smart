import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thèmes Material 3 premium pour Ndako (light + dark).
///
/// Usage dans main.dart :
///   MaterialApp(
///     theme: AppTheme.light,
///     darkTheme: AppTheme.dark,
///     themeMode: themeProvider.themeMode,
///     ...
///   )
class AppTheme {
  AppTheme._();

  /// SystemUiOverlay cohérent avec la palette — à appeler dans main().
  static void applySystemUi({required bool isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? AppColors.darkBg : AppColors.lightBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // ═══════════════════════════════ DARK ════════════════════════════════════
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.accentPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accentPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.accentSecondary,
      onSecondary: Colors.white,
      tertiary: AppColors.accentTertiary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceElevated,
      outline: AppColors.darkBorder,
      error: AppColors.stateDanger,
    );

    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.darkBg,
      canvasColor: AppColors.darkBg,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      shadowColor: Colors.black.withValues(alpha: 0.6),
      textTheme: text,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          side: BorderSide(color: AppColors.accentPrimary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceElevated,
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accentPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stateDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stateDanger, width: 1.8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) return Colors.white;
          return AppColors.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) return AppColors.accentPrimary;
          return AppColors.darkSurfaceElevated;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        selectedColor: AppColors.accentPrimary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
      ),
    );
  }

  // ═══════════════════════════════ LIGHT ═══════════════════════════════════
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.accentPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accentPrimaryDeep,
      onPrimary: Colors.white,
      secondary: AppColors.accentSecondary,
      onSecondary: Colors.white,
      tertiary: AppColors.accentTertiary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceElevated,
      outline: AppColors.lightBorder,
      error: AppColors.stateDanger,
    );

    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    );

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.lightBg,
      canvasColor: AppColors.lightBg,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      textTheme: text,
      iconTheme:
          const IconThemeData(color: AppColors.lightTextPrimary, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimaryDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentPrimaryDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDeep,
          side: BorderSide(color: AppColors.accentPrimaryDeep.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimaryDeep,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.accentPrimaryDeep, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stateDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stateDanger, width: 1.8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) return Colors.white;
          return AppColors.lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) {
            return AppColors.accentPrimaryDeep;
          }
          return AppColors.lightSurfaceElevated;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimaryDeep,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.accentPrimaryDeep,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceElevated,
        selectedColor: AppColors.accentPrimaryDeep.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimaryDeep,
      ),
    );
  }
}
