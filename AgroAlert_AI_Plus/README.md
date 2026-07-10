#  AgroAlert AI+

**L'assistant agricole intelligent pour les producteurs**

Projet réalisé dans le cadre du cours de Développement Mobile — Niveau approfondi (Semaine 6), D-CLIC / OIF.

## À propos

AgroAlert AI+ aide les producteurs agricoles à diagnostiquer les maladies de leurs cultures à partir d'une simple photo, à suivre la météo agricole localisée, et à cartographier leurs observations dans le temps — le tout dans une seule application mobile pensée pour un usage simple sur le terrain.

## Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| 🔐 Authentification | Inscription, connexion, déconnexion (Firebase Authentication) |
| 📸 Scanner IA | Photo (caméra/galerie) → diagnostic IA via [Plant.id](https://plant.id/) (espèce, maladie, confiance, conseils) |
| 📋 Résultat de diagnostic | Affichage détaillé + enregistrement dans l'historique |
| 🗂️ Historique (CRUD) | Créer, consulter, rechercher, trier, modifier, supprimer une analyse |
| 🗺️ Carte SIG | Visualisation des observations géolocalisées sur carte interactive (OpenStreetMap) |
| ⛅ Météo agricole | Données météo localisées + conseil agricole automatique |
| 👤 Profil utilisateur | Consultation du profil, statistiques, déconnexion |

## Captures d'écran

*(à ajouter dans un dossier `/screenshots` et référencer ici, ex. `![Résultat du diagnostic](screenshots/result.png)`)*

## Architecture technique

Le projet suit une architecture en 7 couches :

```
lib/
├── models/         # Classes métier pures (UserModel, CropAnalysis, WeatherModel)
├── screens/        # UI, affichage, interactions utilisateur
├── controllers/    # Logique métier + état Riverpod (AsyncNotifier)
├── services/       # Firebase, API IA (Plant.id), API météo, GPS, stockage local
├── repositories/   # Accès aux données Firestore (CRUD)
├── providers/      # Câblage Riverpod
├── widgets/        # Composants UI réutilisables
├── utils/          # Thème, routeur, constantes
└── main.dart
```

Voir le **dossier de conception technique** (`docs/`) pour le détail complet (gestion d'état, navigation, tests, etc.).

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version stable récente)
- Un projet **Firebase** configuré (Authentication + Firestore), avec votre propre `lib/firebase_options.dart` généré via `flutterfire configure`
- Une clé API **Plant.id / Kindwise** (gratuite avec crédits d'essai) : [admin.kindwise.com](https://admin.kindwise.com/)
- Une clé API **OpenWeatherMap** (gratuite) : [openweathermap.org/api](https://openweathermap.org/api)

## Installation

```bash
# 1. Cloner le dépôt
git clone <url-du-depot>
cd agroalert_ai_plus_app

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase (génère lib/firebase_options.dart)
flutterfire configure

# 4. Lancer l'application avec les clés API
flutter run --dart-define=AI_API_KEY=VOTRE_CLE_PLANT_ID \
            --dart-define=WEATHER_API_KEY=VOTRE_CLE_OPENWEATHERMAP \
            --dart-define=WEATHER_API_BASE_URL=https://api.openweathermap.org/data/2.5
```

⚠️ Aucune clé API n'est codée en dur dans le dépôt : elles doivent être fournies au lancement via `--dart-define`.

## Tests

```bash
flutter test
```

Suite actuelle : 46 tests (modèles, controllers, widgets, parcours d'intégration), tous en succès.

## Limites connues

- Pas de mode hors ligne (connexion internet requise).
- Les photos de culture sont stockées **localement sur l'appareil** (pas de synchronisation entre appareils) — Firebase Storage nécessitant désormais le plan payant Blaze depuis février 2026.
- Pas de gestion multi-langue ni de notifications push dans cette version.

## Documentation complémentaire

- `docs/Cahier_des_charges_AgroAlert_AI+_v1.1.docx`
- `docs/Dossier_conception_technique_AgroAlert_AI+_v1.1.docx`

## Auteur

Projet individuel — D-CLIC, Développement Mobile approfondi, Juillet 2026.
