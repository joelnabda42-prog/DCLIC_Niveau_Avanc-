import 'package:firebase_auth/firebase_auth.dart';

/// Service encapsulant tous les appels à Firebase Authentication.
///
/// Ne contient aucune logique métier ni aucun état Riverpod :
/// uniquement des appels directs au SDK Firebase.
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Flux de l'état de connexion (null = déconnecté).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Utilisateur actuellement connecté (ou null).
  User? get currentUser => _firebaseAuth.currentUser;

  /// Crée un compte avec email/mot de passe et met à jour le displayName.
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  /// Connecte un utilisateur existant avec email/mot de passe.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  /// Envoie un email de réinitialisation de mot de passe.
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
