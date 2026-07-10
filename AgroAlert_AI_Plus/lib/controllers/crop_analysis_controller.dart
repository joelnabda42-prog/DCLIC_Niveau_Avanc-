import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crop_analysis.dart';
import '../providers/auth_providers.dart';
import '../providers/repository_providers.dart';

/// Controller gérant les opérations CRUD (Create/Update/Delete) sur les
/// analyses de cultures. La lecture (READ) est assurée séparément par
/// cropAnalysisListProvider / filteredCropAnalysisProvider, qui
/// s'actualisent automatiquement grâce au flux Firestore temps réel —
/// aucune action manuelle n'est donc nécessaire ici après une écriture.
class CropAnalysisController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// CREATE — Enregistre une nouvelle analyse (issue du Scanner IA).
  Future<bool> save(CropAnalysis analysis) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cropAnalysisRepositoryProvider).create(uid, analysis),
    );
    return !state.hasError;
  }

  /// UPDATE — Met à jour une analyse existante (ex: modification des conseils).
  Future<bool> editAnalysis(CropAnalysis analysis) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cropAnalysisRepositoryProvider).editAnalysis(uid, analysis),
    );
    return !state.hasError;
  }

  /// DELETE — Supprime une analyse par son id.
  Future<bool> delete(String analysisId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cropAnalysisRepositoryProvider).delete(uid, analysisId),
    );
    return !state.hasError;
  }
}

final cropAnalysisControllerProvider =
    AsyncNotifierProvider<CropAnalysisController, void>(
  CropAnalysisController.new,
);
