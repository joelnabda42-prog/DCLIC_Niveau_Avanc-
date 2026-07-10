import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/crop_analysis_controller.dart';
import '../models/crop_analysis.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/custom_button.dart';

/// Écran affichant le résultat du diagnostic IA d'une plante.
/// Reçoit la [CropAnalysis] réelle via `extra` (transmise depuis
/// ScannerScreen ou depuis une carte de l'historique/dashboard).
class ResultScreen extends ConsumerWidget {
  final CropAnalysis? analysis;

  const ResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = this.analysis;

    if (analysis == null) {
      // Cas défensif : accès direct à /result sans donnée transmise.
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: const Text('Résultat du diagnostic'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aucune analyse à afficher. Lancez un nouveau scan.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomButton(
                  label: 'Scanner une plante',
                  onPressed: () => context.go(AppRoutes.scanner),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isSaving = ref.watch(cropAnalysisControllerProvider).isLoading;
    final confidenceColor = analysis.confidence >= 0.75
        ? AppColors.primaryGreen
        : analysis.confidence >= 0.4
            ? AppColors.innovationOrange
            : AppColors.alertRed;

    // Une analyse déjà enregistrée possède un id Firestore non vide.
    final alreadySaved = analysis.id.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        title: const Text('Résultat du diagnostic'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: analysis.imageUrl.isNotEmpty && File(analysis.imageUrl).existsSync()
                ? Image.file(
                    File(analysis.imageUrl),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: AppColors.backgroundLight,
                    child: const Icon(Icons.eco_outlined, size: 48, color: AppColors.textSecondary),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    analysis.cropName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(analysis.confidence * 100).toStringAsFixed(0)}% confiance',
                  style: AppTextStyles.caption.copyWith(
                    color: confidenceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(analysis.disease, style: AppTextStyles.headline2),
          const SizedBox(height: AppSpacing.lg),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: AppColors.innovationOrange),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Conseils agricoles', style: AppTextStyles.title),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(analysis.advice, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          if (!alreadySaved)
            CustomButton(
              label: 'Enregistrer dans l\'historique',
              icon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: () async {
                final success =
                    await ref.read(cropAnalysisControllerProvider.notifier).save(analysis);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analyse enregistrée avec succès ✅')),
                  );
                  context.go(AppRoutes.history);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Échec de l\'enregistrement. Réessayez.')),
                  );
                }
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
          child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Analyse déjà enregistrée dans l\'historique',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          CustomButton(
            label: 'Nouvelle analyse',
            icon: Icons.camera_alt_outlined,
            variant: ButtonVariant.outlined,
            onPressed: () => context.go(AppRoutes.scanner),
          ),
        ],
      ),
    );
  }
}