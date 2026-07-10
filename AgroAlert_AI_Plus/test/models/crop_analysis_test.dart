import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agroalert_ai_plus/models/crop_analysis.dart';

void main() {
  group('CropAnalysis', () {
    final testDate = DateTime(2026, 6, 15, 10, 30);

    final analysis = CropAnalysis(
      id: 'abc123',
      cropName: 'Maïs',
      imageUrl: 'https://example.com/image.jpg',
      disease: 'Rouille du maïs',
      confidence: 0.87,
      advice: 'Traiter sous 48h.',
      latitude: 12.3714,
      longitude: -1.5197,
      date: testDate,
    );

    test('toMap() sérialise correctement tous les champs', () {
      final map = analysis.toMap();

      expect(map['cropName'], 'Maïs');
      expect(map['disease'], 'Rouille du maïs');
      expect(map['confidence'], 0.87);
      expect(map['advice'], 'Traiter sous 48h.');
      expect(map['latitude'], 12.3714);
      expect(map['longitude'], -1.5197);
      expect(map['date'], isA<Timestamp>());
      expect((map['date'] as Timestamp).toDate(), testDate);
      // L'id n'est jamais stocké dans le document lui-même (c'est le doc id).
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap() reconstruit correctement une instance', () {
      final map = {
        'cropName': 'Tomate',
        'imageUrl': 'https://example.com/tomate.jpg',
        'disease': 'Mildiou',
        'confidence': 0.62,
        'advice': 'Réduire l\'humidité.',
        'latitude': 12.37,
        'longitude': -1.51,
        'date': Timestamp.fromDate(testDate),
      };

      final result = CropAnalysis.fromMap('doc42', map);

      expect(result.id, 'doc42');
      expect(result.cropName, 'Tomate');
      expect(result.disease, 'Mildiou');
      expect(result.confidence, 0.62);
      expect(result.date, testDate);
    });

    test('fromMap() gère les champs manquants avec des valeurs par défaut', () {
      final result = CropAnalysis.fromMap('doc1', <String, dynamic>{});

      expect(result.cropName, '');
      expect(result.disease, '');
      expect(result.confidence, 0.0);
      expect(result.advice, '');
      expect(result.latitude, 0.0);
      expect(result.longitude, 0.0);
    });

    test('copyWith() ne modifie que les champs spécifiés', () {
      final updated = analysis.copyWith(advice: 'Nouveau conseil');

      expect(updated.advice, 'Nouveau conseil');
      expect(updated.cropName, analysis.cropName);
      expect(updated.disease, analysis.disease);
      expect(updated.id, analysis.id);
    });
  });
}
