import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente une analyse de culture réalisée par l'IA.
///
/// Contient uniquement les données métier (aucune logique Firebase,
/// aucun appel réseau) conformément à l'architecture MVC du projet.
class CropAnalysis {
  final String id;
  final String cropName;
  final String imageUrl;
  final String disease;
  final double confidence;
  final String advice;
  final double latitude;
  final double longitude;
  final DateTime date;

  const CropAnalysis({
    required this.id,
    required this.cropName,
    required this.imageUrl,
    required this.disease,
    required this.confidence,
    required this.advice,
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  /// Convertit l'instance en Map pour l'écriture dans Firestore.
  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'imageUrl': imageUrl,
      'disease': disease,
      'confidence': confidence,
      'advice': advice,
      'latitude': latitude,
      'longitude': longitude,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Construit une instance à partir d'un document Firestore.
  factory CropAnalysis.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    return CropAnalysis(
      id: id,
      cropName: map['cropName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      disease: map['disease'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      advice: map['advice'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
    );
  }

  /// Retourne une copie de l'analyse avec certains champs modifiés.
  CropAnalysis copyWith({
    String? id,
    String? cropName,
    String? imageUrl,
    String? disease,
    double? confidence,
    String? advice,
    double? latitude,
    double? longitude,
    DateTime? date,
  }) {
    return CropAnalysis(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      imageUrl: imageUrl ?? this.imageUrl,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      advice: advice ?? this.advice,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
    );
  }
}
