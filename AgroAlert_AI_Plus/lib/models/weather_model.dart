/// Représente les données météorologiques agricoles.
///
/// Modèle de données pur, alimenté par le service météo (API externe).
class WeatherModel {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rain;
  final String condition;

  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rain,
    required this.condition,
  });

  /// Convertit l'instance en JSON (utile pour le cache local par ex.).
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rain': rain,
      'condition': condition,
    };
  }

  /// Construit une instance à partir de la réponse JSON de l'API météo.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Inconnu',
    );
  }

  /// Génère un conseil agricole simple basé sur les conditions actuelles.
  String get agriculturalAdvice {
    if (rain > 10) {
      return "Fortes pluies attendues : reportez les traitements phytosanitaires.";
    }
    if (temperature > 35) {
      return "Chaleur intense : pensez à irriguer tôt le matin ou en soirée.";
    }
    if (humidity > 80) {
      return "Humidité élevée : surveillez les risques de maladies fongiques.";
    }
    if (windSpeed > 30) {
      return "Vents forts : évitez la pulvérisation de produits.";
    }
    return "Conditions favorables aux activités agricoles.";
  }
}
