import 'dart:io';
import 'package:flutter/material.dart';

import '../models/crop_analysis.dart';
import '../utils/app_theme.dart';

/// Carte affichant le résumé d'une analyse de culture,
/// utilisée dans l'écran Historique.
class AnalysisCard extends StatelessWidget {
  final CropAnalysis analysis;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const AnalysisCard({
    super.key,
    required this.analysis,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  Color get _confidenceColor {
    if (analysis.confidence >= 0.75) return AppColors.primaryGreen;
    if (analysis.confidence >= 0.4) return AppColors.innovationOrange;
    return AppColors.alertRed;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Row(
            children: [
             ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: analysis.imageUrl.isNotEmpty && File(analysis.imageUrl).existsSync()
                    ? Image.file(
                        File(analysis.imageUrl),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: AppColors.backgroundLight,
                        child: const Icon(Icons.eco_outlined, color: AppColors.textSecondary),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(analysis.cropName, style: AppTextStyles.title.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      analysis.disease,
                      style: AppTextStyles.bodySecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _confidenceColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${(analysis.confidence * 100).toStringAsFixed(0)}% confiance',
                            style: AppTextStyles.caption.copyWith(
                              color: _confidenceColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                   const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${analysis.date.day}/${analysis.date.month}/${analysis.date.year}',
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.alertRed),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
