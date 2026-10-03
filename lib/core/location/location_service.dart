import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../error/exceptions.dart';

class LocationResult {
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.latitude,
    required this.longitude,
  });
}

abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationException(
        type: LocationExceptionType.serviceDisabled,
        message:
            'Location services are turned off. Turn on location to find nearby stores.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        type: LocationExceptionType.permissionDenied,
        message:
            'Location permission was not granted. You can still browse all stores.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        type: LocationExceptionType.permissionDeniedForever,
        message:
            'Location permission is disabled for Bokku Mart. Enable it in your device settings to find nearby stores.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw const LocationException(
        type: LocationExceptionType.timeout,
        message: 'We could not get your location in time. Please try again.',
      );
    } on LocationException {
      rethrow;
    } catch (_) {
      throw const LocationException(
        type: LocationExceptionType.unavailable,
        message:
            'Your location is currently unavailable. You can still browse all stores.',
      );
    }
  }
}
