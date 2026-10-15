import 'dart:async';

import 'package:bokku_mart/core/constants/app_colors.dart';
import 'package:bokku_mart/core/network/api_endpoints.dart';
import 'package:bokku_mart/core/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MobilityTrackingScreen extends ConsumerStatefulWidget {
  const MobilityTrackingScreen({
    super.key,
    required this.serviceType,
    required this.initialJob,
  });

  final String serviceType;
  final Map<String, dynamic> initialJob;

  @override
  ConsumerState<MobilityTrackingScreen> createState() => _MobilityTrackingScreenState();
}

class _MobilityTrackingScreenState extends ConsumerState<MobilityTrackingScreen> {
  static const LatLng _fallbackCenter = LatLng(7.3775, 3.9470);

  final MapController _mapController = MapController();
  Map<String, dynamic> _job = const {};
  Timer? _timer;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _job = Map<String, dynamic>.from(widget.initialJob);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refreshJob());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double? _number(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

  LatLng? _point(dynamic latitude, dynamic longitude) {
    final lat = _number(latitude);
    final lon = _number(longitude);
    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      return null;
    }
    return LatLng(lat, lon);
  }

  Future<void> _refreshJob() async {
    if (!mounted || _refreshing) return;
    final id = _job['id']?.toString();
    if (id == null || id.isEmpty) return;
    setState(() => _refreshing = true);
    try {
      final base = widget.serviceType == 'RIDE' ? ApiEndpoints.rides : ApiEndpoints.parcels;
      final response = await ref.read(dioClientProvider).dio.get('$base$id/');
      final data = Map<String, dynamic>.from(response.data as Map);
      final rawLocation = data['driver_location'];
      if (rawLocation is Map) {
        final point = _point(rawLocation['latitude'], rawLocation['longitude']);
        if (point != null) _mapController.move(point, 15);
      }
      if (mounted) {
        setState(() {
          _job = data;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not refresh tracking right now.');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _point(_job['pickup_latitude'], _job['pickup_longitude']);
    final destination = _point(_job['destination_latitude'], _job['destination_longitude']);
    final location = _job['driver_location'];
    final driverData = location is Map ? Map<String, dynamic>.from(location) : null;
    final driver = driverData == null
        ? null
        : _point(driverData['latitude'], driverData['longitude']);
    final center = driver ?? pickup ?? destination ?? _fallbackCenter;
    final markers = <Marker>[
      if (pickup != null)
        Marker(
          point: pickup,
          width: 44,
          height: 44,
          child: const Icon(Icons.trip_origin, size: 32, color: AppColors.primary),
        ),
      if (destination != null)
        Marker(
          point: destination,
          width: 44,
          height: 44,
          child: const Icon(Icons.flag_circle, size: 36, color: AppColors.error),
        ),
      if (driver != null)
        Marker(
          point: driver,
          width: 52,
          height: 52,
          child: const Icon(Icons.delivery_dining, size: 44, color: AppColors.success),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceType == 'RIDE' ? 'Ride tracking' : 'Parcel tracking'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshJob,
            tooltip: 'Refresh tracking',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: center, initialZoom: driver == null ? 13 : 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bokku.mart',
                ),
                if (markers.isNotEmpty) MarkerLayer(markers: markers),
                const RichAttributionWidget(
                  attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _job['status']?.toString().replaceAll('_', ' ') ?? 'Waiting for status',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text('${_job['pickup_address'] ?? 'Pickup'} → ${_job['destination_address'] ?? 'Destination'}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_job['driver_name']?.toString() ?? 'Waiting for driver assignment')),
                        Text('₦${_job['quoted_fare'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    if (driver == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Live driver coordinates will appear when an assigned driver has a location updated within the last five minutes.'),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                      ),
                    const SizedBox(height: 4),
                    const Text('Map refreshes every 15 seconds while this screen is open.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
