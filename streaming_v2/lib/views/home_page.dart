// ═════════════════════════════════════════════════════════════
// VUE : HomePage
// Page principale de l'application.
// Utilise le contrôleur pour obtenir les données.
// Gère la navigation vers DetailPage après sélection.
// Aucune logique métier — affichage uniquement.
// ═════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/emission_controller.dart';
import 'grille_emissions.dart';
import 'detail_page.dart';

/// Page d'accueil affichant la grille d'émissions.
/// StatefulWidget pour gérer l'index de la barre de navigation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index de l'onglet actif dans la BottomNavigationBar
  int _indexNavigation = 0;

  @override
  void initState() {
    super.initState();
    // Charge les émissions via le contrôleur au démarrage de la page
    Future.microtask(
      () => context.read<EmissionController>().loadEmissions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar : amber avec recherche, titre, menu ──────────
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
      // ── Body : écoute le contrôleur via Consumer ────────────
      // Consumer reconstruit la grille quand notifyListeners() est appelé
      body: Consumer<EmissionController>(
        builder: (context, controller, _) {
          final emissions = controller.getEmissions();
          // Affiche un indicateur de chargement si la liste est vide
          if (emissions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return GrilleEmissions(
            emissions: emissions,
            // Callback : délègue au contrôleur, puis la VUE navigue
            onTap: (emission) {
              final selected = controller.onEmissionSelected(emission);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: DetailPage(emission: selected),
                  ),
                ),
              );
            },
          );
        },
      ),
      // ── BottomNavigationBar : 3 onglets ────────────────────
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
