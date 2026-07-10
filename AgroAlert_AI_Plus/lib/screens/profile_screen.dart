import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../providers/crop_analysis_providers.dart';
import '../providers/user_providers.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/custom_button.dart';

/// Écran Profil utilisateur — branché sur userProfileProvider (Firestore)
/// et cropAnalysisListProvider (pour la statistique du nombre d'analyses).
/// La déconnexion appelle authControllerProvider.signOut().
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final analysesAsync = ref.watch(cropAnalysisListProvider);
    final analysesCount = analysesAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go(AppRoutes.dashboard),
  ),
  title: const Text('Mon profil'),
),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.person, color: Colors.white, size: 44),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  userAsync.value?.name ?? 'Chargement...',
                  style: AppTextStyles.headline2,
                ),
                const SizedBox(height: 2),
                Text(
                  userAsync.value?.email ?? '',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.eco_outlined,
                  label: 'Analyses',
                  value: '$analysesCount',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: _StatCard(
                  icon: Icons.verified_user_outlined,
                  label: 'Compte',
                  value: 'Vérifié',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          CustomButton(
            label: 'Se déconnecter',
            icon: Icons.logout_rounded,
            variant: ButtonVariant.outlined,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.headline2.copyWith(fontSize: 20)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
