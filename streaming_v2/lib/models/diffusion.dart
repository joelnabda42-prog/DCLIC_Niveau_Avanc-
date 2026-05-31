// ═════════════════════════════════════════════════════════════
// MODÈLE : Diffusion + DiffusionService
// Représente un épisode/diffusion d'une émission.
// DiffusionService contient la logique de génération aléatoire.
// Aucune dépendance vers Flutter — logique métier pure.
// ═════════════════════════════════════════════════════════════
import 'dart:math';

/// Représente une diffusion (épisode) d'une émission de streaming.
/// Contient le nom et la date de diffusion.
class Diffusion {
  final String nom;    // Nom de la diffusion (ex: "Diffusion 1")
  final DateTime date; // Date de diffusion

  const Diffusion({required this.nom, required this.date});

  /// Formate la date en chaîne lisible : YYYY-MM-DD
  String get dateFormatee =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  String toString() => 'Diffusion($nom, $dateFormatee)';
}

// ═════════════════════════════════════════════════════════════
// SERVICE : DiffusionService
// Responsable de la génération aléatoire des diffusions.
// C'est de la logique métier → appartient au Modèle.
// ═════════════════════════════════════════════════════════════

/// Service de génération de diffusions aléatoires.
/// Méthode statique utilisée par le contrôleur.
class DiffusionService {
  static final _random = Random();

  /// Génère [nombre] diffusions avec des dates aléatoires en 2023.
  /// Les noms sont mélangés pour simuler un ordre de diffusion réel.
  static List<Diffusion> generer({int nombre = 5}) {
    // Génère les noms et les mélange aléatoirement
    final noms = List.generate(nombre, (i) => 'Diffusion ${i + 1}')
      ..shuffle(_random);

    return noms.map((nom) {
      // Date aléatoire : mois entre 1-12, jour entre 1-28
      final mois = _random.nextInt(12) + 1;
      final jour = _random.nextInt(28) + 1;
      return Diffusion(nom: nom, date: DateTime(2023, mois, jour));
    }).toList();
  }
}
