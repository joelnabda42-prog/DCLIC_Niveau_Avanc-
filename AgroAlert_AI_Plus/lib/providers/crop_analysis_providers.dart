import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crop_analysis.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

/// Flux temps réel de toutes les analyses de l'utilisateur connecté,
/// triées par date décroissante (branché directement sur Firestore).
final cropAnalysisListProvider = StreamProvider<List<CropAnalysis>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(cropAnalysisRepositoryProvider).watchAll(uid);
});

/// Terme de recherche courant, modifiable depuis l'écran Historique.
final cropAnalysisSearchQueryProvider = StateProvider<String>((ref) => '');

/// Ordre de tri courant pour l'écran Historique.
enum CropAnalysisSortOrder { recent, oldest }

final cropAnalysisSortOrderProvider =
    StateProvider<CropAnalysisSortOrder>((ref) => CropAnalysisSortOrder.recent);

/// Liste filtrée + triée, dérivée de [cropAnalysisListProvider].
/// C'est ce provider que l'écran Historique doit observer.
final filteredCropAnalysisProvider = Provider<AsyncValue<List<CropAnalysis>>>((ref) {
  final query = ref.watch(cropAnalysisSearchQueryProvider).toLowerCase();
  final sortOrder = ref.watch(cropAnalysisSortOrderProvider);
  final analysesAsync = ref.watch(cropAnalysisListProvider);

  return analysesAsync.whenData((analyses) {
    var filtered = query.isEmpty
        ? analyses
        : analyses
            .where((a) =>
                a.cropName.toLowerCase().contains(query) ||
                a.disease.toLowerCase().contains(query))
            .toList();

    filtered = [...filtered]
      ..sort((a, b) => sortOrder == CropAnalysisSortOrder.recent
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));

    return filtered;
  });
});
