import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/crop_analysis_controller.dart';
import '../models/crop_analysis.dart';
import '../providers/crop_analysis_providers.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/analysis_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Écran Historique — CRUD complet des analyses de cultures.
///
/// CREATE : via ScannerScreen → ResultScreen → "Enregistrer".
/// READ   : [filteredCropAnalysisProvider] (flux Firestore temps réel,
///          recherche + tri appliqués côté provider).
/// UPDATE : bouton modifier → cropAnalysisControllerProvider.update(...)
/// DELETE : bouton supprimer → cropAnalysisControllerProvider.delete(...)
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, CropAnalysis analysis) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette analyse ?'),
        content: Text('"${analysis.cropName} — ${analysis.disease}" sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(cropAnalysisControllerProvider.notifier)
                  .delete(analysis.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Analyse supprimée' : 'Échec de la suppression'),
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }

  void _editAnalysis(BuildContext context, WidgetRef ref, CropAnalysis analysis) {
    final adviceController = TextEditingController(text: analysis.advice);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Modifier — ${analysis.cropName}'),
        content: TextField(
          controller: adviceController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Conseils agricoles'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final updated = analysis.copyWith(advice: adviceController.text);
              Navigator.pop(dialogContext);
              final success =
                  await ref.read(cropAnalysisControllerProvider.notifier).editAnalysis(updated);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Analyse mise à jour' : 'Échec de la mise à jour'),
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysesAsync = ref.watch(filteredCropAnalysisProvider);
    final sortOrder = ref.watch(cropAnalysisSortOrderProvider);

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go(AppRoutes.dashboard),
  ),
  title: const Text('Historique'),
),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher une culture ou maladie...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) =>
                        ref.read(cropAnalysisSearchQueryProvider.notifier).state = value,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PopupMenuButton<CropAnalysisSortOrder>(
                  icon: const Icon(Icons.sort, color: AppColors.primaryGreen),
                  initialValue: sortOrder,
                  onSelected: (order) =>
                      ref.read(cropAnalysisSortOrderProvider.notifier).state = order,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: CropAnalysisSortOrder.recent,
                      child: Text('Plus récentes'),
                    ),
                    PopupMenuItem(
                      value: CropAnalysisSortOrder.oldest,
                      child: Text('Plus anciennes'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: analysesAsync.when(
                loading: () => const LoadingWidget(message: 'Chargement de vos analyses...'),
                error: (error, _) => AppErrorWidget(
                  message: 'Impossible de charger l\'historique : ${error.toString()}',
                  onRetry: () => ref.invalidate(cropAnalysisListProvider),
                ),
                data: (analyses) {
                  if (analyses.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Aucun résultat',
                      message: 'Aucune analyse ne correspond à votre recherche.',
                      icon: Icons.search_off_rounded,
                    );
                  }
                  return ListView.separated(
                    itemCount: analyses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final analysis = analyses[index];
                      return Dismissible(
                        key: ValueKey(analysis.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.alertRed),
                        ),
                        confirmDismiss: (_) async {
                          _confirmDelete(context, ref, analysis);
                          return false;
                        },
                        child: AnalysisCard(
                          analysis: analysis,
                          onTap: () => context.go(AppRoutes.result, extra: analysis),
                          onEdit: () => _editAnalysis(context, ref, analysis),
                          onDelete: () => _confirmDelete(context, ref, analysis),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nouvelle analyse'),
        onPressed: () => context.go(AppRoutes.scanner),
      ),
    );
  }
}
