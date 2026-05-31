import 'dart:math';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';

void main() {
  runApp(const MonApplication());
}

// ═════════════════════════════════════════════════════════════
// CLASSE : MonApplication
// Point d'entrée de l'application. Hérite de StatelessWidget.
// Configure les paramètres globaux (titre, thème, page d'accueil).
// ═════════════════════════════════════════════════════════════
class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Émissions Streaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MapremierePage(),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CLASSE : MapremierePage
// Page d'accueil de l'application. Hérite de StatefulWidget
// car elle gère l'état de la barre de navigation inférieure.
// ═════════════════════════════════════════════════════════════
class MapremierePage extends StatefulWidget {
  const MapremierePage({super.key});

  @override
  State<MapremierePage> createState() => _MaPremierePageState();
}

class _MaPremierePageState extends State<MapremierePage> {
  // Index de l'onglet actif dans la barre de navigation
  int _indexNavigation = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar : barre amber avec recherche, titre, menu ────
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: const Icon(Icons.search),
        title: const Text(
          'Vos émissions en streaming',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu),
          ),
        ],
      ),
      // ── Body : grille d'émissions ───────────────────────────
      body: const partieGrilleImage(),
      // ── BottomNavigationBar : 3 onglets de navigation ───────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexNavigation,
        onTap: (index) => setState(() => _indexNavigation = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),   label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CLASSE : IdentificationStreaming
// Widget réutilisable représentant une carte d'émission.
// Affiche : image (avec Hero), nom de l'émission, chaîne radio.
// Navigue vers AlbumStreaming au tap via GestureDetector.
// ═════════════════════════════════════════════════════════════
class IdentificationStreaming extends StatelessWidget {
  final String tagStream;    // Tag unique pour la transition Hero
  final String imageStream;  // Chemin de l'image
  final String NomStream;    // Nom de l'émission
  final String ChaineRadio;  // Nom de la chaîne radio

  const IdentificationStreaming({
    super.key,
    required this.tagStream,
    required this.imageStream,
    required this.NomStream,
    required this.ChaineRadio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Au tap : navigation vers la page de détails
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumStreaming(
              tagStream:   tagStream,
              imageStream: imageStream,
              NomStream:   NomStream,
              ChaineRadio: ChaineRadio,
            ),
          ),
        );
      },
      child: Container(
        // Décoration : bords arrondis + ombre portée
        decoration: BoxDecoration(
          color: Colors.white,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ← clé : taille minimale
            children: [
              // ── Image avec animation Hero ───────────────────
              // SizedBox avec hauteur fixe évite l'erreur Expanded
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Hero(
                  tag: tagStream,
                  child: Image.asset(
                    imageStream,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // ── Nom de l'émission et chaîne radio ──────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NomStream,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ChaineRadio,
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

// ═════════════════════════════════════════════════════════════
// CLASSE : partieGrilleImage
// Grille réactive affichant toutes les émissions disponibles.
// ═════════════════════════════════════════════════════════════
class partieGrilleImage extends StatelessWidget {
  const partieGrilleImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridList(
      desiredItemWidth: 160,
      minSpacing: 10,
      children: const [
        IdentificationStreaming(
          tagStream:   'documentaires',
          imageStream: 'assets/images/doc.jpg',
          NomStream:   'Documentaires',
          ChaineRadio: 'Radio 4',
        ),
        IdentificationStreaming(
          tagStream:   'tendances_mode',
          imageStream: 'assets/images/mode.jpg',
          NomStream:   'Tendances Mode',
          ChaineRadio: 'Radio 3',
        ),
        IdentificationStreaming(
          tagStream:   'enquetes_criminelles',
          imageStream: 'assets/images/crime.jpg',
          NomStream:   'Enquêtes Criminelles',
          ChaineRadio: 'Radio 2',
        ),
        IdentificationStreaming(
          tagStream:   'match_foot',
          imageStream: 'assets/images/foot.jpg',
          NomStream:   'Match de Foot',
          ChaineRadio: 'Radio 5',
        ),
        IdentificationStreaming(
          tagStream:   'streaming_meteo',
          imageStream: 'assets/images/meteo.jpg',
          NomStream:   'Streaming Météo',
          ChaineRadio: 'Radio 1',
        ),
        IdentificationStreaming(
          tagStream:   'que_des_news',
          imageStream: 'assets/images/news.jpg',
          NomStream:   'Que des news',
          ChaineRadio: 'Radio 4',
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CLASSE : AlbumStreaming
// Page de détails d'une émission sélectionnée.
// ═════════════════════════════════════════════════════════════
class AlbumStreaming extends StatelessWidget {
  final String tagStream;
  final String imageStream;
  final String NomStream;
  final String ChaineRadio;

  const AlbumStreaming({
    super.key,
    required this.tagStream,
    required this.imageStream,
    required this.NomStream,
    required this.ChaineRadio,
  });

  /// Génère une liste aléatoire de 5 diffusions avec des dates 2023
  List<Map<String, String>> _genererDiffusions() {
    final random = Random();
    final noms = ['Diffusion 1', 'Diffusion 2', 'Diffusion 3', 'Diffusion 4', 'Diffusion 5'];
    noms.shuffle();
    return noms.map((nom) {
      final mois = (random.nextInt(12) + 1).toString().padLeft(2, '0');
      final jour = (random.nextInt(28) + 1).toString().padLeft(2, '0');
      return {'nom': nom, 'date': '2023-$mois-$jour'};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final diffusions = _genererDiffusions();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar : image Hero ───────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: tagStream,
                child: Image.asset(
                  imageStream,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade400,
                    child: const Icon(Icons.image, size: 64, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // ── Bandeau violet ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NomStream,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ChaineRadio,
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final diffusion = diffusions[index];
                return ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: Text('${diffusion['nom']} -'),
                  trailing: Text(
                    'Date: ${diffusion['date']}',
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