import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/app_constants.dart';

class AiDiagnosisResult {
  final String cropName;
  final String disease;
  final double confidence;
  final String advice;

  const AiDiagnosisResult({
    required this.cropName,
    required this.disease,
    required this.confidence,
    required this.advice,
  });
}

class AiService {
  final Dio _dio;

  // Clé Plant.id — récupérée depuis admin.kindwise.com
  static String get _plantIdApiKey => AppConstants.aiApiKey;

  static const String _endpoint =
      'https://api.plant.id/v3/identification?details=common_names&language=fr';

  AiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                headers: {
                  'Content-Type': 'application/json',
                  'Api-Key': _plantIdApiKey,
                },
              ),
            );

  Future<AiDiagnosisResult> analyzeImage(String imageUrl) async {
    return analyzeImageFromUrl(imageUrl);
  }

  /// Analyse une image locale (fichier) avec Plant.id (identification + santé)
  Future<AiDiagnosisResult> analyzeImageFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      return _callPlantId(['data:image/jpeg;base64,$base64Image']);
    } on DioException catch (e) {
      throw AiServiceException(
          'Erreur IA : ${e.response?.data ?? e.message ?? "erreur réseau"}');
    } catch (e) {
      throw AiServiceException('Erreur lors de l\'analyse : $e');
    }
  }

  /// Analyse une image via une URL publique avec Plant.id
  Future<AiDiagnosisResult> analyzeImageFromUrl(String imageUrl) async {
    try {
      return _callPlantId([imageUrl]);
    } on DioException catch (e) {
      throw AiServiceException(
          'Erreur IA : ${e.response?.data ?? e.message ?? "erreur réseau"}');
    } catch (e) {
      throw AiServiceException('Erreur lors de l\'analyse : $e');
    }
  }

  Future<AiDiagnosisResult> _callPlantId(List<String> images) async {
    final response = await _dio.post(
      _endpoint,
      data: {
        'images': images,
        'health': 'all', // demande à la fois identification + santé
        'similar_images': true,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;

    if (result == null) {
      return const AiDiagnosisResult(
        cropName: 'Plante non identifiée',
        disease: 'Analyse indisponible',
        confidence: 0.0,
        advice: 'Reprenez une photo plus nette et bien cadrée sur la feuille.',
      );
    }

    // --- Espèce ---
    final classification = result['classification'] as Map<String, dynamic>?;
    final speciesSuggestions =
        classification?['suggestions'] as List<dynamic>?;
    String cropName = 'Culture inconnue';
    if (speciesSuggestions != null && speciesSuggestions.isNotEmpty) {
      final best = speciesSuggestions.first as Map<String, dynamic>;
      cropName = best['name'] as String? ?? cropName;
    }

    // --- Santé / maladie ---
    final disease = result['disease'] as Map<String, dynamic>?;
    final diseaseSuggestions = disease?['suggestions'] as List<dynamic>?;
    final isHealthy = result['is_healthy'] as Map<String, dynamic>?;
    final healthyBinary = isHealthy?['binary'] as bool? ?? true;

    if (healthyBinary || diseaseSuggestions == null || diseaseSuggestions.isEmpty) {
      return AiDiagnosisResult(
        cropName: cropName,
        disease: 'Aucune maladie détectée',
        confidence: (isHealthy?['probability'] as num?)?.toDouble() ?? 1.0,
        advice: 'La plante semble en bonne santé. Continuez la surveillance régulière.',
      );
    }

    final bestDisease = diseaseSuggestions.first as Map<String, dynamic>;
    final diseaseName = bestDisease['name'] as String? ?? 'Maladie inconnue';
    final diseaseProbability = (bestDisease['probability'] as num?)?.toDouble() ?? 0.0;

    final details = bestDisease['details'] as Map<String, dynamic>?;
    final treatment = details?['treatment'] as Map<String, dynamic>?;
    final biological = treatment?['biological'];
    final chemical = treatment?['chemical'];
    final prevention = treatment?['prevention'];

    final adviceParts = <String>[];
    if (prevention != null) adviceParts.add('Prévention : $prevention');
    if (biological != null) adviceParts.add('Solution naturelle : $biological');
    if (chemical != null) adviceParts.add('Traitement chimique : $chemical');

    return AiDiagnosisResult(
      cropName: cropName,
      disease: diseaseName,
      confidence: diseaseProbability,
      advice: adviceParts.isNotEmpty
          ? adviceParts.join('\n')
          : 'Consultez un agronome local pour confirmer le diagnostic.',
    );
  }
}

class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);
  @override
  String toString() => message;
}