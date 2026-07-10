import 'package:flutter_test/flutter_test.dart';

import 'package:agroalert_ai_plus/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    test('fromJson() reconstruit correctement une instance', () {
      final json = {
        'temperature': 29.5,
        'humidity': 68.0,
        'windSpeed': 12.0,
        'rain': 0.0,
        'condition': 'Clear',
      };

      final weather = WeatherModel.fromJson(json);

      expect(weather.temperature, 29.5);
      expect(weather.humidity, 68.0);
      expect(weather.windSpeed, 12.0);
      expect(weather.rain, 0.0);
      expect(weather.condition, 'Clear');
    });

    test('fromJson() gère les champs manquants avec des valeurs par défaut', () {
      final weather = WeatherModel.fromJson(<String, dynamic>{});

      expect(weather.temperature, 0.0);
      expect(weather.humidity, 0.0);
      expect(weather.windSpeed, 0.0);
      expect(weather.rain, 0.0);
      expect(weather.condition, 'Inconnu');
    });

    test('toJson() sérialise correctement tous les champs', () {
      const weather = WeatherModel(
        temperature: 25,
        humidity: 50,
        windSpeed: 8,
        rain: 2.5,
        condition: 'Rain',
      );

      final json = weather.toJson();

      expect(json['temperature'], 25);
      expect(json['humidity'], 50);
      expect(json['windSpeed'], 8);
      expect(json['rain'], 2.5);
      expect(json['condition'], 'Rain');
    });

    group('agriculturalAdvice', () {
      test('alerte en cas de fortes pluies', () {
        const weather = WeatherModel(
          temperature: 24,
          humidity: 60,
          windSpeed: 10,
          rain: 15,
          condition: 'Rain',
        );
        expect(weather.agriculturalAdvice, contains('pluies'));
      });

      test('alerte en cas de forte chaleur', () {
        const weather = WeatherModel(
          temperature: 38,
          humidity: 40,
          windSpeed: 5,
          rain: 0,
          condition: 'Clear',
        );
        expect(weather.agriculturalAdvice, contains('irriguer'));
      });

      test('alerte en cas d\'humidité élevée', () {
        const weather = WeatherModel(
          temperature: 28,
          humidity: 85,
          windSpeed: 5,
          rain: 0,
          condition: 'Clouds',
        );
        expect(weather.agriculturalAdvice, contains('fongiques'));
      });

      test('alerte en cas de vents forts', () {
        const weather = WeatherModel(
          temperature: 27,
          humidity: 50,
          windSpeed: 35,
          rain: 0,
          condition: 'Clear',
        );
        expect(weather.agriculturalAdvice, contains('pulvérisation'));
      });

      test('conditions favorables si aucun seuil n\'est dépassé', () {
        const weather = WeatherModel(
          temperature: 26,
          humidity: 55,
          windSpeed: 10,
          rain: 0,
          condition: 'Clear',
        );
        expect(weather.agriculturalAdvice, 'Conditions favorables aux activités agricoles.');
      });
    });
  });
}
