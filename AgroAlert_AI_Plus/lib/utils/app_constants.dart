/// Constantes globales de configuration (endpoints, clés API).
///
/// ⚠️ Pour un rendu de production, ces valeurs doivent être injectées via
/// des variables d'environnement (--dart-define) ou un fichier .env
/// exclu du dépôt Git, et non codées en dur ici.
class AppConstants {
  AppConstants._();

  // --- API IA multimodale (diagnostic de plantes) ---
  static const String aiApiBaseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'https://api.exemple-ia-agricole.com/v1',
  );

  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );

  // --- API météo agricole ---
  static const String weatherApiBaseUrl = String.fromEnvironment(
    'WEATHER_API_BASE_URL',
    defaultValue: 'https://api.openweathermap.org/data/2.5',
  );

  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );

  // --- Collections Firestore ---
  static const String usersCollection = 'users';
  static const String cropAnalysesCollection = 'crop_analyses';
}
