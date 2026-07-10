import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Indicateur de chargement standardisé, avec message optionnel.
/// À utiliser pour tout état "loading" dans les écrans.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
