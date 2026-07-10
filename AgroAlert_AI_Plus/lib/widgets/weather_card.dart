import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/app_theme.dart';

/// Carte affichant les données météo agricoles courantes,
/// utilisée sur le Dashboard et l'écran Météo.
class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  IconData get _conditionIcon {
    switch (weather.condition.toLowerCase()) {
      case 'rain':
      case 'pluie':
        return Icons.water_drop_outlined;
      case 'clouds':
      case 'nuages':
        return Icons.cloud_outlined;
      case 'clear':
      case 'clair':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.thermostat_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°C',
                    style: AppTextStyles.headline1.copyWith(color: Colors.white),
                  ),
                  Text(
                    weather.condition,
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Icon(_conditionIcon, color: Colors.white, size: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _WeatherMetric(icon: Icons.water_drop, label: '${weather.humidity.toStringAsFixed(0)}%'),
              const SizedBox(width: AppSpacing.lg),
              _WeatherMetric(icon: Icons.air, label: '${weather.windSpeed.toStringAsFixed(0)} km/h'),
              const SizedBox(width: AppSpacing.lg),
              _WeatherMetric(icon: Icons.grain, label: '${weather.rain.toStringAsFixed(1)} mm'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    weather.agriculturalAdvice,
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WeatherMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySecondary.copyWith(color: Colors.white)),
      ],
    );
  }
}
