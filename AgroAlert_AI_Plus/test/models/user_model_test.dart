import 'package:flutter_test/flutter_test.dart';

import 'package:agroalert_ai_plus/models/user_model.dart';

void main() {
  group('UserModel', () {
    const user = UserModel(
      uid: 'uid123',
      name: 'Aïcha Traoré',
      email: 'aicha@example.com',
    );

    test('toMap() sérialise correctement tous les champs', () {
      final map = user.toMap();

      expect(map['uid'], 'uid123');
      expect(map['name'], 'Aïcha Traoré');
      expect(map['email'], 'aicha@example.com');
    });

    test('fromMap() reconstruit correctement une instance', () {
      final map = {
        'uid': 'uid456',
        'name': 'Ibrahim Ouédraogo',
        'email': 'ibrahim@example.com',
      };

      final result = UserModel.fromMap(map);

      expect(result.uid, 'uid456');
      expect(result.name, 'Ibrahim Ouédraogo');
      expect(result.email, 'ibrahim@example.com');
    });

    test('fromMap() gère les champs manquants avec des chaînes vides', () {
      final result = UserModel.fromMap(<String, dynamic>{});

      expect(result.uid, '');
      expect(result.name, '');
      expect(result.email, '');
    });

    test('copyWith() ne modifie que le champ spécifié', () {
      final updated = user.copyWith(name: 'Nouveau nom');

      expect(updated.name, 'Nouveau nom');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
    });

    test('round-trip toMap() → fromMap() préserve les données', () {
      final result = UserModel.fromMap(user.toMap());

      expect(result.uid, user.uid);
      expect(result.name, user.name);
      expect(result.email, user.email);
    });
  });
}
