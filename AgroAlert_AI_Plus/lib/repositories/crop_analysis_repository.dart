import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/crop_analysis.dart';
import '../utils/app_constants.dart';

/// Repository gérant le CRUD complet des analyses de cultures (CropAnalysis)
/// dans Cloud Firestore, pour un utilisateur donné.
///
/// Structure Firestore utilisée :
/// users/{uid}/crop_analyses/{analysisId}
class CropAnalysisRepository {
  final FirebaseFirestore _firestore;

  CropAnalysisRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _analysesRef(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.cropAnalysesCollection);
  }

  /// CREATE — Ajoute une nouvelle analyse et retourne son id généré.
  Future<String> create(String uid, CropAnalysis analysis) async {
    final docRef = await _analysesRef(uid).add(analysis.toMap());
    return docRef.id;
  }

  /// READ — Flux temps réel de toutes les analyses, triées par date
  /// décroissante (les plus récentes en premier).
  Stream<List<CropAnalysis>> watchAll(String uid) {
    return _analysesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CropAnalysis.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// READ — Récupère une analyse unique par son id.
  Future<CropAnalysis?> getById(String uid, String analysisId) async {
    final doc = await _analysesRef(uid).doc(analysisId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CropAnalysis.fromMap(doc.id, doc.data()!);
  }

  /// UPDATE — Met à jour une analyse existante.
  Future<void> editAnalysis(String uid, CropAnalysis analysis) {
    return _analysesRef(uid).doc(analysis.id).update(analysis.toMap());
  }

  /// DELETE — Supprime une analyse par son id.
  Future<void> delete(String uid, String analysisId) {
    return _analysesRef(uid).doc(analysisId).delete();
  }

  /// Recherche + filtre simple côté client par nom de culture ou maladie.
  /// (Firestore ne supportant pas nativement la recherche plein texte.)
  Stream<List<CropAnalysis>> search(String uid, String query) {
    final lowerQuery = query.toLowerCase();
    return watchAll(uid).map((analyses) => analyses.where((a) {
          return a.cropName.toLowerCase().contains(lowerQuery) ||
              a.disease.toLowerCase().contains(lowerQuery);
        }).toList());
  }
}
