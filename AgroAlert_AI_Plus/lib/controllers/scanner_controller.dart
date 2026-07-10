import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/crop_analysis.dart';
import '../providers/auth_providers.dart';
import '../providers/service_providers.dart';

class ScannerController extends AsyncNotifier<CropAnalysis?> {
  @override
  FutureOr<CropAnalysis?> build() => null;

  Future<CropAnalysis?> analyzeCrop(File imageFile) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError(
        Exception('Vous devez être connecté pour analyser une plante.'),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncLoading();

    final aiService = ref.read(aiServiceProvider);
    final locationService = ref.read(locationServiceProvider);

    try {
      // 1. Récupération de la position GPS
      final position = await locationService.getCurrentPosition();

      // 2. Sauvegarde locale de la photo (stockage sur l'appareil,
      // Firebase Storage nécessitant désormais le plan payant Blaze)
      final localImagePath = await _saveImageLocally(imageFile, uid);

      // 3. Appel au service IA (Plant.id) avec le fichier image
      final diagnosis = await aiService.analyzeImageFile(imageFile);

      // 4. Construction du modèle CropAnalysis
      final analysis = CropAnalysis(
        id: '',
        cropName: diagnosis.cropName,
        imageUrl: localImagePath,
        disease: diagnosis.disease,
        confidence: diagnosis.confidence,
        advice: diagnosis.advice,
        latitude: position.latitude,
        longitude: position.longitude,
        date: DateTime.now(),
      );

      state = AsyncData(analysis);
      return analysis;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Copie la photo prise dans le dossier de documents de l'application,
  /// et retourne le chemin local (utilisé ensuite comme "imageUrl").
  Future<String> _saveImageLocally(File imageFile, String uid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cropImagesDir = Directory('${appDir.path}/crop_images/$uid');
    if (!await cropImagesDir.exists()) {
      await cropImagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await imageFile.copy('${cropImagesDir.path}/$fileName');
    return savedFile.path;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final scannerControllerProvider =
    AsyncNotifierProvider<ScannerController, CropAnalysis?>(
  ScannerController.new,
);