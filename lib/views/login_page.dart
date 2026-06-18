// FILE: lib/views/login_page.dart
import 'package:flutter/material.dart';

import '../models/utilisateur.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'gestion_maisons_page.dart';
import 'signup_page.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({Key? key}) : super(key: key);

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';
  bool _obscureText = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final Utilisateur utilisateur =
          await AuthService().login(email.trim(), password.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GestionMaisonsPage(utilisateur: utilisateur),
        ),
      );
    } on ApiException catch (e) {
      String message;
      if (e.statusCode == 401 || e.statusCode == 400) {
        message = "Email ou mot de passe incorrect.";
      } else if (e.statusCode == 0) {
        message = "Impossible de joindre le serveur : ${e.message}";
      } else {
        message = e.message;
      }
      setState(() => errorMessage = message);
    } catch (e) {
      setState(() => errorMessage = "Une erreur est survenue : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fond : gradient dark premium + halos lumineux flous.
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF050816), Color(0xFF0A0E1A), Color(0xFF111B33)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFEFF3FB), Color(0xFFE5EBF8), Color(0xFFDFE6F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      body: Stack(
        children: [
          // Fond gradient
          Container(decoration: BoxDecoration(gradient: bgGradient)),
          // Halo top-right
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(
              color: AppColors.accentPrimary.withValues(alpha: isDark ? 0.45 : 0.18),
              size: 320,
            ),
          ),
          // Halo bottom-left
          Positioned(
            bottom: -140,
            left: -100,
            child: _Glow(
              color: AppColors.accentSecondary.withValues(alpha: isDark ? 0.35 : 0.16),
              size: 360,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      // Logo badge
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPrimary
                                    .withValues(alpha: 0.45),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        "Bienvenue",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Connectez-vous pour piloter votre maison Ndako",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Form glass card
                      GlassCard(
                        padding: const EdgeInsets.all(22),
                        borderRadius: 22,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (v) => email = v,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  hintText: "ex: demo@ndako.local",
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? "Ce champ est requis"
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                onChanged: (v) => password = v,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelText: "Mot de passe",
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureText = !_obscureText),
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? "Ce champ est requis"
                                    : null,
                              ),
                              if (errorMessage.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _ErrorBanner(message: errorMessage),
                              ],
                              const SizedBox(height: 22),
                              GradientButton(
                                label: "Se connecter",
                                icon: Icons.arrow_forward_rounded,
                                loading: isLoading,
                                onPressed: _login,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Pas encore de compte ?  ",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InscriptionPage()),
                            ),
                            child: Text(
                              "Inscrivez-vous",
                              style: TextStyle(
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        "Ndako © 2026",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              .withValues(alpha: 0.6),
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Halo de lumière flouté utilisé en arrière-plan.
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Banner d'erreur stylisé.
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.stateDanger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.stateDanger.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.stateDanger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.stateDanger,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
