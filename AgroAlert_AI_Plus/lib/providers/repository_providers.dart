import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/user_repository.dart';
import '../repositories/crop_analysis_repository.dart';

/// Providers exposant une instance unique de chaque repository.
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

final cropAnalysisRepositoryProvider =
    Provider<CropAnalysisRepository>((ref) => CropAnalysisRepository());
