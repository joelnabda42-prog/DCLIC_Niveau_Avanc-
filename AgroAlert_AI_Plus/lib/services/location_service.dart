import 'package:geolocator/geolocator.dart';

/// Service encapsulant les appels à Geolocator (permissions + position GPS).
class LocationService {
  /// Vérifie/demande les permissions puis retourne la position actuelle.
  ///
  /// Lève une [LocationServiceException] si le service de localisation
  /// est désactivé ou si la permission est refusée.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Le service de localisation est désactivé sur cet appareil.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'La permission de localisation a été refusée.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'La permission de localisation est bloquée définitivement. '
        'Veuillez l\'activer dans les paramètres de l\'application.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Flux de mise à jour continue de la position (utile pour la carte SIG).
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}

/// Exception dédiée aux erreurs de géolocalisation.
class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}
