import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agroalert_ai_plus/widgets/empty_state_widget.dart';
import 'package:agroalert_ai_plus/widgets/error_widget.dart';
import 'package:agroalert_ai_plus/widgets/loading_widget.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('EmptyStateWidget', () {
    testWidgets('affiche le titre, le message et l\'icône fournis', (tester) async {
      await tester.pumpWidget(wrap(
        const EmptyStateWidget(
          title: 'Aucune analyse',
          message: 'Scannez votre première plante.',
          icon: Icons.eco_outlined,
        ),
      ));

      expect(find.text('Aucune analyse'), findsOneWidget);
      expect(find.text('Scannez votre première plante.'), findsOneWidget);
      expect(find.byIcon(Icons.eco_outlined), findsOneWidget);
    });

    testWidgets('affiche le widget action quand il est fourni', (tester) async {
      await tester.pumpWidget(wrap(
        EmptyStateWidget(
          title: 'Vide',
          message: 'Rien ici',
          action: ElevatedButton(onPressed: () {}, child: const Text('Ajouter')),
        ),
      ));

      expect(find.text('Ajouter'), findsOneWidget);
    });
  });

  group('AppErrorWidget', () {
    testWidgets('affiche le message d\'erreur', (tester) async {
      await tester.pumpWidget(wrap(
        const AppErrorWidget(message: 'Une erreur est survenue'),
      ));

      expect(find.text('Une erreur est survenue'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('affiche le bouton Réessayer et déclenche onRetry', (tester) async {
      var retried = false;

      await tester.pumpWidget(wrap(
        AppErrorWidget(
          message: 'Erreur réseau',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Réessayer'), findsOneWidget);
      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('n\'affiche pas de bouton si onRetry est absent', (tester) async {
      await tester.pumpWidget(wrap(
        const AppErrorWidget(message: 'Erreur'),
      ));

      expect(find.text('Réessayer'), findsNothing);
    });
  });

  group('LoadingWidget', () {
    testWidgets('affiche le spinner et le message optionnel', (tester) async {
      await tester.pumpWidget(wrap(
        const LoadingWidget(message: 'Chargement...'),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Chargement...'), findsOneWidget);
    });
  });
}
