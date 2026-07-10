import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/crop_analysis_providers.dart';
import '../providers/user_providers.dart';
import '../providers/weather_providers.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/weather_card.dart';
import '../widgets/analysis_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final userAsync = ref.watch(userProfileProvider);
    final analysesAsync = ref.watch(cropAnalysisListProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            ref.invalidate(weatherProvider);
            ref.invalidate(cropAnalysisListProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour 👋', style: AppTextStyles.bodySecondary),
                        Text(
                          userAsync.value?.name ?? 'Producteur',
                          style: AppTextStyles.headline2,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.profile),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

            weatherAsync.when(
                data: (weather) => WeatherCard(weather: weather),
                loading: () => const SizedBox(
                  height: 160,
                  child: LoadingWidget(message: 'Récupération de la météo...'),
                ),
                error: (error, _) => AppErrorWidget(
                  message: 'Météo indisponible. Vérifiez votre connexion internet.',
                  onRetry: () => ref.invalidate(weatherProvider),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Actions rapides', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.4,
                children: [
                  DashboardCard(
                    title: 'Scanner plante',
                    subtitle: 'Analyse IA',
                    icon: Icons.camera_alt_outlined,
                    color: AppColors.primaryGreen,
                    onTap: () => context.go(AppRoutes.scanner),
                  ),
                  DashboardCard(
                    title: 'Météo',
                    subtitle: 'Conditions agricoles',
                    icon: Icons.wb_sunny_outlined,
                    color: AppColors.innovationOrange,
                    onTap: () => context.go(AppRoutes.weather),
                  ),
                  DashboardCard(
                    title: 'Carte',
                    subtitle: 'Vos observations',
                    icon: Icons.map_outlined,
                    color: AppColors.lightGreen,
                    onTap: () => context.go(AppRoutes.map),
                  ),
                  DashboardCard(
                    title: 'Historique',
                    subtitle: 'Toutes vos analyses',
                    icon: Icons.history_rounded,
                    color: AppColors.alertRed,
                    onTap: () => context.go(AppRoutes.history),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dernières analyses', style: AppTextStyles.title),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.history),
                    child: const Text('Tout voir'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              analysesAsync.when(
                data: (analyses) {
                  if (analyses.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Aucune analyse',
                      message: 'Scannez votre première plante pour commencer.',
                      icon: Icons.eco_outlined,
                    );
                  }
                  final recent = analyses.take(3).toList();
                  return Column(
                    children: recent
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AnalysisCard(
                                analysis: a,
                                onTap: () => context.go(AppRoutes.result, extra: a),
                              ),
                            ))
                        .toList(),
                  );
                },
                loading: () => const LoadingWidget(
                  message: 'Chargement de vos analyses...',
                ),
                error: (error, _) => AppErrorWidget(
                  message: 'Impossible de charger l\'historique : ${error.toString()}',
                  onRetry: () => ref.invalidate(cropAnalysisListProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}