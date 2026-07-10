import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:agroalert_ai_plus/controllers/scanner_controller.dart';
import 'package:agroalert_ai_plus/providers/auth_providers.dart';
import 'package:agroalert_ai_plus/providers/service_providers.dart';
import 'package:agroalert_ai_plus/services/ai_service.dart';

import '../mocks/mock_services.dart';

class MockPosition extends Mock implements Position {}

/// Fausse implémentation de path_provider, pour rediriger le dossier
/// "documents de l'application" vers un dossier temporaire pendant les tests.
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  FakePathProviderPlatform(this.tempPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;
}

void main() {
  late MockStorageService storageService;
  late MockAiService aiService;
  late MockLocationService locationService;
  late ProviderContainer container;
  late File dummyImage;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(File('dummy.jpg'));
  });

  setUp(() async {
    storageService = MockStorageService();
    aiService = MockAiService();
    locationService = MockLocationService();

    // Dossier temporaire utilisé comme faux "dossier documents" de l'app.
    tempDir = await Directory.systemTemp.createTemp('scanner_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    // Fausse photo de test (contenu factice, juste pour tester la copie de fichier).
    dummyImage = File('${tempDir.path}/source_dummy.jpg');
    await dummyImage.writeAsBytes([0, 1, 2, 3]);

    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        aiServiceProvider.overrideWithValue(aiService),
        locationServiceProvider.overrideWithValue(locationService),
        currentUidProvider.overrideWithValue('test-uid'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('analyzeCrop() enregistre la photo localement, appelle GPS puis IA, et retourne une CropAnalysis', () async {
    final mockPosition = MockPosition();
    when(() => mockPosition.latitude).thenReturn(12.3714);
    when(() => mockPosition.longitude).thenReturn(-1.5197);

    when(() => locationService.getCurrentPosition()).thenAnswer((_) async => mockPosition);
    when(() => aiService.analyzeImageFile(any())).thenAnswer(
      (_) async => const AiDiagnosisResult(
        cropName: 'Maïs',
        disease: 'Rouille du maïs',
        confidence: 0.87,
        advice: 'Traiter sous 48h.',
      ),
    );

    final controller = container.read(scannerControllerProvider.notifier);
    final result = await controller.analyzeCrop(dummyImage);

    expect(result, isNotNull);
    expect(result!.cropName, 'Maïs');
    expect(result.disease, 'Rouille du maïs');
    expect(result.confidence, 0.87);
    expect(result.latitude, 12.3714);
    expect(result.longitude, -1.5197);

    // La photo doit avoir été copiée localement : le chemin renvoyé existe bien.
    expect(result.imageUrl, isNotEmpty);
    expect(File(result.imageUrl).existsSync(), isTrue);

    // Firebase Storage ne doit plus être sollicité (stockage local désormais).
    verifyNever(() => storageService.uploadCropImage(
        uid: any(named: 'uid'), imageFile: any(named: 'imageFile')));
    verify(() => aiService.analyzeImageFile(dummyImage)).called(1);
  });

  test('retourne null et expose une erreur si l\'utilisateur n\'est pas connecté', () async {
    final anonContainer = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        aiServiceProvider.overrideWithValue(aiService),
        locationServiceProvider.overrideWithValue(locationService),
        currentUidProvider.overrideWithValue(null),
      ],
    );
    addTearDown(anonContainer.dispose);

    final controller = anonContainer.read(scannerControllerProvider.notifier);
    final result = await controller.analyzeCrop(dummyImage);

    expect(result, isNull);
    expect(anonContainer.read(scannerControllerProvider).hasError, isTrue);
    verifyNever(() => aiService.analyzeImageFile(any()));
  });

  test('propage l\'échec si l\'API IA lève une exception', () async {
    final mockPosition = MockPosition();
    when(() => mockPosition.latitude).thenReturn(12.3714);
    when(() => mockPosition.longitude).thenReturn(-1.5197);

    when(() => locationService.getCurrentPosition()).thenAnswer((_) async => mockPosition);
    when(() => aiService.analyzeImageFile(any()))
        .thenThrow(AiServiceException('Service indisponible'));

    final controller = container.read(scannerControllerProvider.notifier);
    final result = await controller.analyzeCrop(dummyImage);

    expect(result, isNull);
    expect(container.read(scannerControllerProvider).hasError, isTrue);
  });
}