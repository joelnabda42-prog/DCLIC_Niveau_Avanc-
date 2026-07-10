import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agroalert_ai_plus/controllers/crop_analysis_controller.dart';
import 'package:agroalert_ai_plus/models/crop_analysis.dart';
import 'package:agroalert_ai_plus/providers/auth_providers.dart';
import 'package:agroalert_ai_plus/providers/repository_providers.dart';

import '../mocks/mock_services.dart';

void main() {
  late MockCropAnalysisRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(testCropAnalysis);
  });

  setUp(() {
    repository = MockCropAnalysisRepository();
    container = ProviderContainer(
      overrides: [
        cropAnalysisRepositoryProvider.overrideWithValue(repository),
        // Simule un utilisateur connecté sans avoir besoin de mocker
        // tout le flux Firebase Auth (currentUidProvider est un simple Provider).
        currentUidProvider.overrideWithValue('test-uid'),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('CropAnalysisController.save (CREATE)', () {
    test('appelle repository.create avec le bon uid et retourne true', () async {
      when(() => repository.create('test-uid', any())).thenAnswer((_) async => 'new-id');

      final controller = container.read(cropAnalysisControllerProvider.notifier);
      final result = await controller.save(testCropAnalysis);

      expect(result, isTrue);
      verify(() => repository.create('test-uid', testCropAnalysis)).called(1);
    });

    test('retourne false si Firestore lève une exception', () async {
      when(() => repository.create(any(), any())).thenThrow(Exception('network error'));

      final controller = container.read(cropAnalysisControllerProvider.notifier);
      final result = await controller.save(testCropAnalysis);

      expect(result, isFalse);
    });
  });

  group('CropAnalysisController.update (UPDATE)', () {
    test('appelle repository.update avec l\'analyse modifiée', () async {
      final updated = testCropAnalysis.copyWith(advice: 'Nouveau conseil');
      when(() => repository.editAnalysis('test-uid', updated)).thenAnswer((_) async {});

      final controller = container.read(cropAnalysisControllerProvider.notifier);
      final result = await controller.editAnalysis(updated);

      expect(result, isTrue);
      verify(() => repository.editAnalysis('test-uid', updated)).called(1);
    });
  });

  group('CropAnalysisController.delete (DELETE)', () {
    test('appelle repository.delete avec le bon id et retourne true', () async {
      when(() => repository.delete('test-uid', 'test-id')).thenAnswer((_) async {});

      final controller = container.read(cropAnalysisControllerProvider.notifier);
      final result = await controller.delete('test-id');

      expect(result, isTrue);
      verify(() => repository.delete('test-uid', 'test-id')).called(1);
    });

    test('retourne false si l\'utilisateur n\'est pas connecté', () async {
      final anonContainer = ProviderContainer(
        overrides: [
          cropAnalysisRepositoryProvider.overrideWithValue(repository),
          currentUidProvider.overrideWithValue(null),
        ],
      );
      addTearDown(anonContainer.dispose);

      final controller = anonContainer.read(cropAnalysisControllerProvider.notifier);
      final result = await controller.delete('test-id');

      expect(result, isFalse);
      verifyNever(() => repository.delete(any(), any()));
    });
  });
}
