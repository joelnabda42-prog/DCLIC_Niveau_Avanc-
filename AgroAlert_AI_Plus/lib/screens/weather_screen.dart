import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';

import '../providers/weather_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/weather_card.dart';

/// Écran Météo agricole détaillé — branché sur weatherProvider
/// (position GPS réelle + appel à l'API météo externe).
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go(AppRoutes.dashboard),
  ),
  title: const Text('Météo agricole'),
),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async => ref.invalidate(weatherProvider),
        child: weatherAsync.when(
          loading: () => const LoadingWidget(message: 'Récupération de la météo...'),
          error: (error, _) => AppErrorWidget(
            message: 'Météo indisponible : ${error.toString()}',
            onRetry: () => ref.invalidate(weatherProvider),
          ),
          data: (weather) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              WeatherCard(weather: weather),
              const SizedBox(height: AppSpacing.xl),
              Text('Prévisions & recommandations', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              _InfoTile(
                icon: Icons.water_drop_outlined,
                label: 'Humidité relative',
                value: '${weather.humidity.toStringAsFixed(0)}%',
              ),
              _InfoTile(
                icon: Icons.air,
                label: 'Vitesse du vent',
                value: '${weather.windSpeed.toStringAsFixed(0)} km/h',
              ),
              _InfoTile(
                icon: Icons.grain,
                label: 'Précipitations (1h)',
                value: '${weather.rain.toStringAsFixed(1)} mm',
              ),
              _InfoTile(
                icon: Icons.thermostat_outlined,
                label: 'Condition générale',
                value: weather.condition,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
