// ═════════════════════════════════════════════════════════════
// CONTRÔLEUR : EmissionController
// Coordonne le Modèle et les Vues.
// Responsabilités :
//   - Charger et exposer la liste des émissions
//   - Gérer la sélection d'une émission
//   - Déléguer la génération des diffusions au Modèle
//
// Règles MVC respectées :
//   ✅ Pas de widgets Flutter
//   ✅ Pas de Navigator.push direct
//   ✅ Notifie les vues via ChangeNotifier
// ═════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import '../models/emission.dart';
import '../models/diffusion.dart';

/// Contrôleur principal de l'application.
/// Étend ChangeNotifier pour notifier les vues des changements d'état.
class EmissionController extends ChangeNotifier {
  // ── État privé ────────────────────────────────────────────
  List<Emission> _emissions = [];         // Liste de toutes les émissions
  Emission? _emissionSelectionnee;        // Émission actuellement sélectionnée

  // ── Getters publics (lecture seule) ──────────────────────

  /// Retourne une copie non modifiable de la liste des émissions
  List<Emission> get emissions => List.unmodifiable(_emissions);

  /// Retourne l'émission actuellement sélectionnée (peut être null)
  Emission? get emissionSelectionnee => _emissionSelectionnee;

  // ── Méthodes publiques ────────────────────────────────────

  /// Charge la liste des émissions (données simulées/mockées).
  /// En production, cette méthode ferait un appel API ou base de données.
  void loadEmissions() {
    _emissions = [
      const Emission(
        id: 'doc',
        nom: 'Documentaires',
        chaineRadio: 'Radio 4',
        imageStream: 'assets/images/doc.jpg',
      ),
      const Emission(
        id: 'mode',
        nom: 'Tendances Mode',
        chaineRadio: 'Radio 3',
        imageStream: 'assets/images/mode.jpg',
      ),
      const Emission(
        id: 'crime',
        nom: 'Enquêtes Criminelles',
        chaineRadio: 'Radio 2',
        imageStream: 'assets/images/crime.jpg',
      ),
      const Emission(
        id: 'foot',
        nom: 'Match de Foot',
        chaineRadio: 'Radio 5',
        imageStream: 'assets/images/foot.jpg',
      ),
      const Emission(
        id: 'meteo',
        nom: 'Streaming Météo',
        chaineRadio: 'Radio 1',
        imageStream: 'assets/images/meteo.jpg',
      ),
      const Emission(
        id: 'news',
        nom: 'Que des news',
        chaineRadio: 'Radio 4',
        imageStream: 'assets/images/news.jpg',
      ),
    ];
    // Notifie les vues que les données ont changé
    notifyListeners();
  }

  /// Retourne la liste complète des émissions chargées.
  List<Emission> getEmissions() => _emissions;

  /// Enregistre l'émission sélectionnée et notifie les vues.
  /// Retourne l'émission choisie pour que la vue puisse naviguer.
  /// Note : la navigation elle-même est gérée par la Vue (HomePage).
  Emission onEmissionSelected(Emission emission) {
    _emissionSelectionnee = emission;
    notifyListeners();
    return emission;
  }

  /// Délègue la génération des diffusions au service du Modèle.
  /// Le contrôleur ne génère pas lui-même les données — il délègue.
  List<Diffusion> getDiffusions(Emission emission, {int nombre = 5}) {
    return DiffusionService.generer(nombre: nombre);
  }
}
