import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'service_providers.dart';

/// Position GPS courante de l'utilisateur (permissions gérées par
/// LocationService). Utilisé par la Météo et la Carte SIG.
final currentPositionProvider = FutureProvider<Position>((ref) {
  return ref.watch(locationServiceProvider).getCurrentPosition();
});

/// Météo agricole courante, basée sur la position GPS de l'utilisateur.
final weatherProvider = FutureProvider<WeatherModel>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.watch(weatherServiceProvider).getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
});
