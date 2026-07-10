import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Carte d'action rapide affichée sur le Dashboard
/// (ex: 📷 Scanner plante, 🌦 Météo, 🗺 Carte , 📚 Historique).
class DashboardCard extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  final Color color;

  final VoidCallback onTap;



  const DashboardCard({

    super.key,

    required this.title,

    required this.subtitle,

    required this.icon,

    required this.onTap,

    this.color = AppColors.primaryGreen,

  });



  @override

  Widget build(BuildContext context) {

    return Material(

      color: AppColors.surface,

      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),

      child: InkWell(

        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),

        onTap: onTap,

        child: Container(

          padding: const EdgeInsets.all(AppSpacing.sm),

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),

            border: Border.all(color: AppColors.divider),

          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisSize: MainAxisSize.min,

            children: [

              Container(

                padding: const EdgeInsets.all(6),

                decoration: BoxDecoration(

                  color: color.withOpacity(0.12),

                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),

                ),

                child: Icon(icon, color: color, size: 22),

              ),

              const SizedBox(height: 6),

              Text(

                title,

                style: AppTextStyles.title.copyWith(fontSize: 14),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

              ),

              const SizedBox(height: 2),

              Text(

                subtitle,

                style: AppTextStyles.caption,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

              ),

            ],

          ),

        ),

      ),

    );

  }

}