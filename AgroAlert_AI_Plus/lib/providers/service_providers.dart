import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

/// Providers exposant une instance unique de chaque service.
/// Permettent l'injection de dépendances et facilitent les tests
/// (un service peut être "overridé" par un mock dans les tests Riverpod).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
