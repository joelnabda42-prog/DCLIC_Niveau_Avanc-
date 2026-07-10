import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agroalert_ai_plus/widgets/custom_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('CustomButton', () {
    testWidgets('affiche le label et déclenche onPressed au tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(wrap(
        CustomButton(
          label: 'Se connecter',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Se connecter'), findsOneWidget);

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('affiche un spinner et masque le label pendant le chargement', (tester) async {
      await tester.pumpWidget(wrap(
        CustomButton(
          label: 'Se connecter',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Se connecter'), findsNothing);
    });

    testWidgets('n\'appelle pas onPressed quand isLoading est true', (tester) async {
      var tapped = false;

      await tester.pumpWidget(wrap(
        CustomButton(
          label: 'Se connecter',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('n\'appelle pas onPressed quand il est null (bouton désactivé)', (tester) async {
      await tester.pumpWidget(wrap(
        const CustomButton(
          label: 'Analyser',
          onPressed: null,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('affiche un OutlinedButton pour la variante outlined', (tester) async {
      await tester.pumpWidget(wrap(
        CustomButton(
          label: 'Annuler',
          variant: ButtonVariant.outlined,
          onPressed: () {},
        ),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
