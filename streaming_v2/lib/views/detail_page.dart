// ═════════════════════════════════════════════════════════════
// VUE : DetailPage
// Page de détails d'une émission sélectionnée.
// Reçoit l'émission via constructeur.
// Les diffusions sont obtenues via le contrôleur (pas générées ici).
// Aucune logique métier — affichage uniquement.
// ═════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emission.dart';
import '../controllers/emission_controller.dart';

/// Page de détail d'une émission.
/// Affiche : image Hero, bandeau violet, liste de diffusions.
class DetailPage extends StatelessWidget {
  final Emission emission; // Émission à afficher (reçue via constructeur)

  const DetailPage({super.key, required this.emission});

  @override
  Widget build(BuildContext context) {
    // Obtient les diffusions depuis le contrôleur (qui délègue au Modèle)
    // La logique de génération n'est PAS dans la vue
    final diffusions = context.read<EmissionController>().getDiffusions(emission);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar : image Hero + icône cœur ──────────
          // L'image s'étend sur 280px et reste visible au scroll
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            actions: const [
              // Icône cœur (favoris — non implémentée dans cette version)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                // Même tag que CarteEmission → transition fluide
                tag: emission.id,
                child: Image.asset(
                  emission.imageStream,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade400,
                    child: const Icon(Icons.image, size: 64, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // ── Bandeau violet : nom + chaîne radio ────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.deepPurple, // Violet comme dans l'énoncé
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'émission en blanc gras
                  Text(
                    emission.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Chaîne radio en blanc semi-transparent
                  Text(
                    emission.chaineRadio,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Liste des diffusions ────────────────────────────
          // Chaque ligne : icône volume + nom diffusion + date
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final diffusion = diffusions[index];
                return ListTile(
                  leading: const Icon(Icons.volume_up), // Icône volume
                  title: Text('${diffusion.nom} -'),
                  trailing: Text(
                    'Date: ${diffusion.dateFormatee}',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              },
              childCount: diffusions.length,
            ),
          ),
        ],
      ),
    );
  }
}
