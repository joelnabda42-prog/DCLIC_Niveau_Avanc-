// ═════════════════════════════════════════════════════════════
// MODÈLE : Emission
// Représente les données d'une émission de streaming.
// Aucune dépendance vers Flutter — logique de données pure.
// ═════════════════════════════════════════════════════════════

/// Classe de données représentant une émission de streaming.
/// Contient uniquement les propriétés et aucune logique d'affichage.
class Emission {
  final String id;           // Identifiant unique (utilisé pour le tag Hero)
  final String nom;          // Nom de l'émission
  final String chaineRadio;  // Nom de la chaîne radio
  final String imageStream;  // Chemin vers l'image de l'émission

  const Emission({
    required this.id,
    required this.nom,
    required this.chaineRadio,
    required this.imageStream,
  });

  @override
  String toString() => 'Emission($nom, $chaineRadio)';
}
