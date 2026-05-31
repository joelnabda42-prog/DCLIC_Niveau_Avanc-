// ═════════════════════════════════════════════════════════════
// VUE : CarteEmission
// Widget purement visuel représentant une carte d'émission.
// Reçoit les données via constructeur — aucune logique métier.
// ═════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../models/emission.dart';

/// Widget visuel d'une carte d'émission dans la grille.
/// Affiche l'image (avec Hero), le nom et la chaîne radio.
/// Déclenche [onTap] au tap — remonte l'action au contrôleur.
class CarteEmission extends StatelessWidget {
  final Emission emission; // Données de l'émission à afficher
  final VoidCallback onTap; // Callback déclenché au tap (géré par le contrôleur)

  const CarteEmission({
    super.key,
    required this.emission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Décoration : bords arrondis + ombre portée
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          // Remonte le tap au contrôleur via le callback
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image avec animation Hero ───────────────────
              // Le tag Hero = emission.id pour une transition fluide
              Expanded(
                child: Hero(
                  tag: emission.id,
                  child: Image.asset(
                    emission.imageStream,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    // Icône de remplacement si l'image est absente
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // ── Nom et chaîne radio ─────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de l'émission en gras
                    Text(
                      emission.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Chaîne radio en gris
                    Text(
                      emission.chaineRadio,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
