import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/service_providers.dart';
import '../providers/repository_providers.dart';

/// Controller gérant les actions d'authentification (inscription, connexion,
/// déconnexion) et exposant un état [AsyncValue] exploitable directement
/// par les écrans (loading / error / data) via Riverpod.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Rien à initialiser : l'état de connexion réel est exposé par
    // authStateChangesProvider (providers/auth_providers.dart).
  }

  /// Connecte un utilisateur existant. Retourne `true` en cas de succès.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    state = await AsyncValue.guard(
      () => authService.signIn(email: email, password: password),
    );
    return !state.hasError;
  }

  /// Crée un compte, puis enregistre le profil dans Firestore.
  /// Retourne `true` en cas de succès.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);
    final userRepository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final credential = await authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('Impossible de récupérer l\'identifiant utilisateur.');
      }
      await userRepository.saveUser(UserModel(uid: uid, name: name, email: email));
    });
    return !state.hasError;
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

/// Traduit les erreurs Firebase Auth en messages lisibles en français,
/// pour affichage direct dans les SnackBar / bannières d'erreur des écrans.
String mapAuthErrorToMessage(Object? error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
        return 'Aucun compte ne correspond à cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Problème de connexion réseau. Réessayez.';
      default:
        return error.message ?? 'Une erreur est survenue. Réessayez.';
    }
  }
  return 'Une erreur est survenue. Réessayez.';
}
