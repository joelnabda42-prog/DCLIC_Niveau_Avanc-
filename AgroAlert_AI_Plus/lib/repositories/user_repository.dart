import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../utils/app_constants.dart';

/// Repository gérant l'accès aux données utilisateur dans Firestore.
///
/// Ne contient aucune logique d'authentification (voir AuthService) :
/// uniquement la persistance du profil utilisateur (nom, email, stats...).
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  /// Crée ou met à jour le document profil d'un utilisateur.
  Future<void> saveUser(UserModel user) {
    return _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Récupère le profil d'un utilisateur à partir de son uid.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Flux temps réel du profil utilisateur.
  Stream<UserModel?> watchUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }
}
