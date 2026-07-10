import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Service encapsulant les appels à Firebase Storage.
///
/// Utilisé notamment pour héberger les photos de plantes prises
/// par l'utilisateur avant analyse par l'IA.
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload une image de culture et retourne son URL de téléchargement.
  ///
  /// [uid] identifie le dossier de l'utilisateur pour organiser les fichiers.
  Future<String> uploadCropImage({
    required String uid,
    required File imageFile,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('crop_images/$uid/$fileName');

    final uploadTask = await ref.putFile(imageFile);
    return uploadTask.ref.getDownloadURL();
  }

  /// Supprime une image à partir de son URL de téléchargement.
  Future<void> deleteImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // L'image a peut-être déjà été supprimée : on ignore l'erreur
      // pour ne pas bloquer la suppression de l'analyse associée.
    }
  }
}
