import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agroalert_ai_plus/models/crop_analysis.dart';
import 'package:agroalert_ai_plus/repositories/crop_analysis_repository.dart';
import 'package:agroalert_ai_plus/repositories/user_repository.dart';
import 'package:agroalert_ai_plus/services/ai_service.dart';
import 'package:agroalert_ai_plus/services/auth_service.dart';
import 'package:agroalert_ai_plus/services/location_service.dart';
import 'package:agroalert_ai_plus/services/storage_service.dart';
import 'package:agroalert_ai_plus/services/weather_service.dart';

/// Mocks des services (couche Firebase / IA / météo / GPS), utilisés
/// pour isoler les controllers de toute dépendance réseau dans les tests.
class MockAuthService extends Mock implements AuthService {}

class MockStorageService extends Mock implements StorageService {}

class MockAiService extends Mock implements AiService {}

class MockWeatherService extends Mock implements WeatherService {}

class MockLocationService extends Mock implements LocationService {}

/// Mocks des repositories (accès Firestore).
class MockUserRepository extends Mock implements UserRepository {}

class MockCropAnalysisRepository extends Mock implements CropAnalysisRepository {}

/// Mocks Firebase Auth (types concrets renvoyés par AuthService).
class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

/// Jeu de données de test réutilisable.
final testCropAnalysis = CropAnalysis(
  id: 'test-id',
  cropName: 'Maïs',
  imageUrl: 'https://example.com/image.jpg',
  disease: 'Rouille du maïs',
  confidence: 0.87,
  advice: 'Traiter sous 48h.',
  latitude: 12.3714,
  longitude: -1.5197,
  date: DateTime(2026, 6, 15),
);
