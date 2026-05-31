// ═════════════════════════════════════════════════════════════
// VUE : GrilleEmissions
// Affiche la grille réactive de toutes les émissions.
// Reçoit la liste et le callback — aucune logique métier.
// ═════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../models/emission.dart';
import 'carte_emission.dart';

/// Grille réactive affichant une liste d'émissions.
/// Utilise [ResponsiveGridList] pour s'adapter à la taille d'écran.
/// Chaque élément est un [CarteEmission] avec son callback [onTap].
class GrilleEmissions extends StatelessWidget {
  final List<Emission> emissions; // Liste des émissions à afficher
  final void Function(Emission) onTap; // Callback au tap (remonte au contrôleur)

  const GrilleEmissions({
    super.key,
    required this.emissions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridList(
      desiredItemWidth: 160, // Largeur souhaitée de chaque carte
      minSpacing: 10,        // Espacement minimum entre les cartes
      // Crée une CarteEmission pour chaque émission de la liste
      children: emissions
          .map((e) => CarteEmission(emission: e, onTap: () => onTap(e)))
          .toList(),
    );
  }
}
