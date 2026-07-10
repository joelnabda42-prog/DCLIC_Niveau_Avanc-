import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'service_providers.dart';

/// Flux temps réel de l'état de connexion Firebase.
/// `null` = utilisateur déconnecté, sinon l'utilisateur Firebase courant.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Utilisateur Firebase courant (synchronisé sur [authStateChangesProvider]).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

/// uid courant, pratique pour paramétrer les autres providers
/// (historique, profil...). `null` si personne n'est connecté.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});
