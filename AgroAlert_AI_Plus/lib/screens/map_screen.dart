import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_router.dart';

import '../models/crop_analysis.dart';
import '../providers/crop_analysis_providers.dart';
import '../providers/weather_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Écran Carte SIG — visualise en temps réel la position GPS de
/// l'utilisateur et l'ensemble de ses observations géolocalisées
/// (branché sur currentPositionProvider et cropAnalysisListProvider).
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);
    final analysesAsync = ref.watch(cropAnalysisListProvider);

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go(AppRoutes.dashboard),
  ),
  title: const Text('Carte SIG'),
),
      body: positionAsync.when(
        loading: () => const LoadingWidget(message: 'Localisation en cours...'),
        error: (error, _) => AppErrorWidget(
          message: 'Impossible d\'accéder à votre position : ${error.toString()}',
          onRetry: () => ref.invalidate(currentPositionProvider),
        ),
        data: (position) {
          final center = LatLng(position.latitude, position.longitude);
          final analyses = analysesAsync.value ?? <CropAnalysis>[];

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.agroalert.aiplus',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 46,
                    height: 46,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
                  ...analyses.map(
                    (a) => Marker(
                      point: LatLng(a.latitude, a.longitude),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _showObservationSheet(context, a),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.eco, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showObservationSheet(BuildContext context, CropAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(analysis.cropName, style: AppTextStyles.headline2),
            const SizedBox(height: AppSpacing.xs),
            Text(analysis.disease, style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(analysis.confidence * 100).toStringAsFixed(0)}% de confiance',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
