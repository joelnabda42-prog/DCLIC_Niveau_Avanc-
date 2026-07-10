import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

/// Flux temps réel du profil Firestore de l'utilisateur connecté.
/// Retourne `null` si personne n'est connecté ou si le profil n'existe pas.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
