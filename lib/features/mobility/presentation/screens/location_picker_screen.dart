import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.label,
    this.initialLatitude,
    this.initialLongitude,
  });

  final String label;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _ibadanCenter = LatLng(7.3775, 3.9470);

  final MapController _mapController = MapController();
  final Dio _geocoder = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org/',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: const {'User-Agent': 'BokkuMart/1.0', 'Accept': 'application/json'},
  ));

  LatLng? _selected;
  bool _busy = false;
  String? _error;

  LatLng get _initialCenter {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      return LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
    return _ibadanCenter;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selected = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services to use your current position.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required to use your current position.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _selected = point;
        _error = null;
      });
      _mapController.move(point, 16);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final point = _selected;
    if (point == null) {
      setState(() => _error = 'Tap the map to choose a location first.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    var address = 'Lat ${point.latitude.toStringAsFixed(6)}, Lon ${point.longitude.toStringAsFixed(6)}';
    try {
      final response = await _geocoder.get(
        'reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': point.latitude,
          'lon': point.longitude,
          'zoom': 18,
          'addressdetails': 1,
        },
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final displayName = body['display_name']?.toString().trim();
      if (displayName != null && displayName.isNotEmpty) {
        address = displayName.length > 255 ? displayName.substring(0, 255) : displayName;
      }
    } catch (_) {
      // Keep a usable coordinate address when reverse geocoding is unavailable.
    }
    if (!mounted) return;
    Navigator.of(context).pop(<String, dynamic>{
      'latitude': point.latitude,
      'longitude': point.longitude,
      'address': address,
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = _initialCenter;
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose ${widget.label.toLowerCase()} location'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _selected == null ? 13 : 16,
              onTap: (_, point) => setState(() {
                _selected = point;
                _error = null;
              }),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bokku.mart',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_pin, size: 44, color: AppColors.primary),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Move the map and tap the exact ${widget.label.toLowerCase()} point. Use the GPS button for your current location.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Card(
                      color: AppColors.errorSurface,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                      ),
                    ),
                  if (_selected != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${_selected!.latitude.toStringAsFixed(6)}, ${_selected!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _useCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use GPS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _confirm,
                          icon: _busy
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check),
                          label: const Text('Confirm location'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
