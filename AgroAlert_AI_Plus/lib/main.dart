import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/app_theme.dart';
import 'utils/app_router.dart';
import 'firebase_options.dart';

/// Point d'entrée de l'application AgroAlert AI+
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase (Auth, Firestore, Storage)
  // ⚠️ Nécessite d'avoir exécuté `flutterfire configure` au préalable
  // pour remplacer lib/firebase_options.dart par vos vraies clés.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: AgroAlertApp(),
    ),
  );
}

/// Widget racine de l'application
class AgroAlertApp extends ConsumerWidget {
  const AgroAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AgroAlert AI+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
