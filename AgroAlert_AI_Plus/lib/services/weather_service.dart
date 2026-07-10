import 'package:dio/dio.dart';

import '../models/weather_model.dart';
import '../utils/app_constants.dart';

/// Service encapsulant l'appel à l'API météo externe.
class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.weatherApiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  /// Récupère la météo actuelle pour une position GPS donnée.
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final main = data['main'] as Map<String, dynamic>? ?? {};
      final wind = data['wind'] as Map<String, dynamic>? ?? {};
      final rainData = data['rain'] as Map<String, dynamic>?;
      final weatherList = data['weather'] as List<dynamic>? ?? [];

      return WeatherModel.fromJson({
        'temperature': main['temp'],
        'humidity': main['humidity'],
        'windSpeed': wind['speed'],
        'rain': rainData?['1h'] ?? 0.0,
        'condition': weatherList.isNotEmpty
            ? weatherList.first['main'] as String?
            : 'Inconnu',
      });
    } on DioException catch (e) {
      throw WeatherServiceException(
        'Erreur lors de la récupération de la météo : ${e.message ?? "erreur réseau"}',
      );
    }
  }
}

/// Exception dédiée aux erreurs du service météo.
class WeatherServiceException implements Exception {
  final String message;
  WeatherServiceException(this.message);

  @override
  String toString() => message;
}
