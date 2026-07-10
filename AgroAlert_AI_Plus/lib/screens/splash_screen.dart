import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';

/// Écran d'accueil affiché au lancement de l'application.
/// Affiche le logo, une animation, puis redirige vers le Dashboard si
/// l'utilisateur est déjà connecté (Firebase Auth), sinon vers le Login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirectWhenReady();
  }

  Future<void> _redirectWhenReady() async {
    // Laisse le temps à l'animation de se jouer tout en attendant que
    // Firebase Auth restaure une éventuelle session existante.
    final stopwatch = Stopwatch()..start();

    User? user;
    try {
      user = await ref.read(authStateChangesProvider.future);
    } catch (_) {
      user = null;
    }

    final remaining = 1800 - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (!mounted) return;
    context.go(user != null ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/agroalert_icon_1024.jpg',
                width: 560,
                height: 560,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'AgroAlert AI+',
              style: AppTextStyles.headline1.copyWith(color: Colors.white),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "L'assistant agricole intelligent pour les producteurs",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
