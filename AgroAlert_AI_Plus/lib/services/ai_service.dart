import 'package:dio/dio.dart';

import '../utils/app_constants.dart';

/// Résultat brut retourné par le service d'analyse IA,
/// avant transformation en modèle métier [CropAnalysis].
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

  factory AiDiagnosisResult.fromJson(Map<String, dynamic> json) {
    return AiDiagnosisResult(
      cropName: json['crop_name'] as String? ?? 'Culture inconnue',
      disease: json['disease'] as String? ?? 'Aucune maladie détectée',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      advice: json['advice'] as String? ??
          'Aucun conseil disponible pour le moment.',
    );
  }
}

/// Service encapsulant l'appel à l'API IA multimodale de diagnostic
/// de plantes (analyse d'image → maladie + conseils).
class AiService {
  final Dio _dio;

  AiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.aiApiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  if (AppConstants.aiApiKey.isNotEmpty)
                    'Authorization': 'Bearer ${AppConstants.aiApiKey}',
                },
              ),
            );

  /// Envoie l'URL de l'image (déjà uploadée sur Firebase Storage)
  /// à l'API IA et retourne le diagnostic.
  Future<AiDiagnosisResult> analyzeImage(String imageUrl) async {
    try {
      final response = await _dio.post(
        '/analyze',
        data: {'image_url': imageUrl},
      );
      return AiDiagnosisResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw AiServiceException(
        'Erreur lors de l\'analyse IA : ${e.message ?? "erreur réseau"}',
      );
    }
  }
}

/// Exception dédiée aux erreurs du service IA, pour un traitement
/// différencié dans les controllers (affichage d'un message clair).
class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);

  @override
  String toString() => message;
}
