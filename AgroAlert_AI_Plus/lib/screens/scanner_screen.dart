import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/scanner_controller.dart';
import '../utils/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/custom_button.dart';

/// Écran de scan d'une plante par l'IA.
///
/// Parcours réel : Photo (caméra/galerie) → Firebase Storage →
/// position GPS → API IA multimodale → CropAnalysis → ResultScreen
/// (via scannerControllerProvider).
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;

    final analysis = await ref
        .read(scannerControllerProvider.notifier)
        .analyzeCrop(_selectedImage!);

    if (!mounted) return;

    if (analysis != null) {
      context.go(AppRoutes.result, extra: analysis);
    } else {
      final error = ref.read(scannerControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'analyse : ${error ?? "erreur inconnue"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = ref.watch(scannerControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go(AppRoutes.dashboard),
  ),
  title: const Text('Scanner une plante'),
),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_search_rounded,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Prenez ou choisissez une photo de votre culture',
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Caméra',
                    icon: Icons.camera_alt_outlined,
                    variant: ButtonVariant.outlined,
                    onPressed: isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    label: 'Galerie',
                    icon: Icons.photo_library_outlined,
                    variant: ButtonVariant.outlined,
                    onPressed: isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CustomButton(
              label: 'Analyser avec l\'IA',
              icon: Icons.auto_awesome_outlined,
              isLoading: isAnalyzing,
              onPressed: _selectedImage == null ? null : _analyze,
            ),
          ],
        ),
      ),
    );
  }
}
