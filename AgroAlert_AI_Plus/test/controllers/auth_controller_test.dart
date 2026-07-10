import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agroalert_ai_plus/controllers/auth_controller.dart';
import 'package:agroalert_ai_plus/models/user_model.dart';
import 'package:agroalert_ai_plus/providers/repository_providers.dart';
import 'package:agroalert_ai_plus/providers/service_providers.dart';

import '../mocks/mock_services.dart';

void main() {
  late MockAuthService authService;
  late MockUserRepository userRepository;
  late ProviderContainer container;

  setUpAll(() {
    // Nécessaire pour que mocktail sache générer une valeur factice
    // pour les arguments nommés typés UserModel dans any(named: ...).
    registerFallbackValue(const UserModel(uid: '', name: '', email: ''));
  });

  setUp(() {
    authService = MockAuthService();
    userRepository = MockUserRepository();

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AuthController.signIn', () {
    test('retourne true et expose un état data en cas de succès', () async {
      when(() => authService.signIn(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => MockUserCredential());

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signIn(email: 'test@agro.ai', password: '123456');

      expect(result, isTrue);
      expect(container.read(authControllerProvider).hasError, isFalse);
      verify(() => authService.signIn(email: 'test@agro.ai', password: '123456')).called(1);
    });

    test('retourne false et expose l\'erreur en cas d\'échec', () async {
      when(() => authService.signIn(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signIn(email: 'test@agro.ai', password: 'bad');

      expect(result, isFalse);
      expect(container.read(authControllerProvider).hasError, isTrue);
    });
  });

  group('AuthController.signUp', () {
    test('crée le compte puis enregistre le profil Firestore', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('new-uid');
      when(() => mockCredential.user).thenReturn(mockUser);

      when(() => authService.signUp(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);
      when(() => userRepository.saveUser(any())).thenAnswer((_) async {});

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signUp(
        name: 'Aïcha',
        email: 'aicha@agro.ai',
        password: '123456',
      );

      expect(result, isTrue);
      verify(() => userRepository.saveUser(any(
            that: isA<UserModel>()
                .having((u) => u.uid, 'uid', 'new-uid')
                .having((u) => u.name, 'name', 'Aïcha'),
          ))).called(1);
    });

    test('retourne false si Firebase Auth échoue', () async {
      when(() => authService.signUp(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signUp(
        name: 'Aïcha',
        email: 'existe@agro.ai',
        password: '123456',
      );

      expect(result, isFalse);
      verifyNever(() => userRepository.saveUser(any()));
    });
  });

  group('AuthController.signOut', () {
    test('appelle bien AuthService.signOut()', () async {
      when(() => authService.signOut()).thenAnswer((_) async {});

      final controller = container.read(authControllerProvider.notifier);
      await controller.signOut();

      verify(() => authService.signOut()).called(1);
    });
  });

  group('mapAuthErrorToMessage', () {
    test('traduit les codes d\'erreur Firebase connus en français', () {
      expect(
        mapAuthErrorToMessage(FirebaseAuthException(code: 'user-not-found')),
        contains('Aucun compte'),
      );
      expect(
        mapAuthErrorToMessage(FirebaseAuthException(code: 'weak-password')),
        contains('faible'),
      );
    });

    test('retourne un message générique pour une erreur inconnue', () {
      expect(mapAuthErrorToMessage(Exception('boom')), isNotEmpty);
    });
  });
}
