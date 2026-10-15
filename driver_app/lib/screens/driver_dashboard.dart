import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/driver_api.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key, required this.api, required this.onLogout});
  final DriverApi api;
  final VoidCallback onLogout;

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _rides = const [];
  List<Map<String, dynamic>> _myRides = const [];
  List<Map<String, dynamic>> _parcels = const [];
  List<Map<String, dynamic>> _myParcels = const [];
  final _plate = TextEditingController();
  final _make = TextEditingController();
  final _color = TextEditingController();
  final _deliveryCode = TextEditingController();
  String _vehicle = 'MOTORCYCLE';
  bool _busy = false;
  bool _available = false;
  String? _message;
  Timer? _foregroundTrackingTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _foregroundTrackingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _refreshWhileOnline();
    });
  }

  @override
  void dispose() {
    _foregroundTrackingTimer?.cancel();
    _plate.dispose();
    _make.dispose();
    _color.dispose();
    _deliveryCode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _busy = true; _message = null; });
    try {
      try {
        _profile = await widget.api.profile();
        _available = _profile?['is_available'] == true;
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          _profile = null;
        } else {
          rethrow;
        }
      }
      if (_profile != null && _profile!['is_approved'] == true && _profile!['is_suspended'] != true) {
        if (_available) {
          _rides = await widget.api.availableRides();
          _parcels = await widget.api.availableParcels();
        }
        _myRides = await widget.api.myRides();
        _myParcels = await widget.api.myParcels();
      } else {
        _rides = const [];
        _parcels = const [];
        _myRides = const [];
        _myParcels = const [];
      }
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshWhileOnline() async {
    if (!mounted || _busy) return;
    final approved = _profile?['is_approved'] == true && _profile?['is_suspended'] != true;
    final hasActiveWork = _myRides.isNotEmpty || _myParcels.isNotEmpty;
    if (!approved || (!_available && !hasActiveWork)) return;
    setState(() => _busy = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)),
      );
      await widget.api.updateLocation(position.latitude, position.longitude);
      if (_available) {
        _rides = await widget.api.availableRides();
        _parcels = await widget.api.availableParcels();
      }
      _myRides = await widget.api.myRides();
      _myParcels = await widget.api.myParcels();
    } catch (_) {
      // Keep the last good screen state if a foreground location refresh fails.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateLocation() async {
    setState(() { _busy = true; _message = null; });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw StateError('Enable device location to go online.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required for driver dispatch.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      await widget.api.updateLocation(position.latitude, position.longitude);
      _message = 'Your location was updated.';
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setAvailable(bool value) async {
    setState(() { _busy = true; _message = null; });
    try {
      await widget.api.setAvailability(value);
      _available = value;
      await _load();
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createProfile() async {
    setState(() { _busy = true; _message = null; });
    try {
      _profile = await widget.api.createProfile(
        vehicleType: _vehicle,
        plate: _plate.text,
        make: _make.text,
        color: _color.text,
      );
      _message = 'Vehicle profile submitted. An operations administrator must approve it before you can go online.';
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptRide(Map<String, dynamic> wrapped) async {
    final ride = Map<String, dynamic>.from(wrapped['ride'] as Map);
    await _run(() async { await widget.api.acceptRide(ride['id'].toString()); });
  }

  Future<void> _acceptParcel(Map<String, dynamic> wrapped) async {
    final parcel = Map<String, dynamic>.from(wrapped['parcel'] as Map);
    await _run(() async { await widget.api.acceptParcel(parcel['id'].toString()); });
  }

  Future<void> _rideStatus(Map<String, dynamic> ride) async {
    final status = ride['status']?.toString();
    final next = status == 'DRIVER_ASSIGNED'
        ? 'DRIVER_ARRIVING'
        : status == 'DRIVER_ARRIVING'
            ? 'IN_PROGRESS'
            : status == 'IN_PROGRESS'
                ? 'COMPLETED'
                : null;
    if (next == null) return;
    await _run(() async => widget.api.updateRideStatus(ride['id'].toString(), next));
  }

  Future<void> _parcelStatus(Map<String, dynamic> parcel) async {
    final status = parcel['status']?.toString();
    final next = status == 'DRIVER_ASSIGNED'
        ? 'PICKED_UP'
        : status == 'PICKED_UP'
            ? 'IN_TRANSIT'
            : status == 'IN_TRANSIT'
                ? 'DELIVERED'
                : null;
    if (next == null) return;
    String? code;
    if (next == 'DELIVERED') {
      code = _deliveryCode.text.trim();
      if (code.isEmpty) {
        setState(() => _message = 'Enter the recipient delivery code before completing delivery.');
        return;
      }
    }
    await _run(() async => widget.api.updateParcelStatus(
      parcel['id'].toString(), next, deliveryCode: code,
    ));
    if (next == 'DELIVERED') _deliveryCode.clear();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() { _busy = true; _message = null; });
    try {
      await action();
      await _load();
      _message = 'Update saved.';
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _section(String title, List<Map<String, dynamic>> items, Widget Function(Map<String, dynamic>) builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        if (items.isEmpty) const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Nothing here right now.'),
        ) else ...items.map(builder),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final approved = _profile?['is_approved'] == true && _profile?['is_suspended'] != true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bokku Driver'),
        actions: [IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_message != null) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_message!))),
            if (_profile == null) ...[
              const Text('Set up your vehicle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _vehicle,
                items: const [
                  DropdownMenuItem(value: 'MOTORCYCLE', child: Text('Motorcycle')),
                  DropdownMenuItem(value: 'CAR', child: Text('Car')),
                ],
                onChanged: _busy ? null : (value) => setState(() => _vehicle = value ?? 'MOTORCYCLE'),
                decoration: const InputDecoration(labelText: 'Vehicle type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(controller: _plate, decoration: const InputDecoration(labelText: 'Vehicle plate', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _make, decoration: const InputDecoration(labelText: 'Vehicle make (optional)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _color, decoration: const InputDecoration(labelText: 'Vehicle colour (optional)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              FilledButton(onPressed: _busy ? null : _createProfile, child: const Text('Submit vehicle profile')),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_profile!['vehicle_type']} • ${_profile!['vehicle_plate']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Text(approved ? 'Driver approved' : (_profile!['is_suspended'] == true ? 'Driver suspended — contact support' : 'Awaiting operations approval')),
                    if (approved) ...[
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        OutlinedButton.icon(onPressed: _busy ? null : _updateLocation, icon: const Icon(Icons.my_location), label: const Text('Update location')),
                        FilledButton.icon(
                          onPressed: _busy ? null : () => _setAvailable(!_available),
                          icon: Icon(_available ? Icons.pause_circle_outline : Icons.play_circle_outline),
                          label: Text(_available ? 'Go offline' : 'Go online'),
                        ),
                      ]),
                    ],
                  ]),
                ),
              ),
              if (approved && _available) ...[
                _section('Nearby ride requests', _rides, (wrapped) {
                  final ride = Map<String, dynamic>.from(wrapped['ride'] as Map);
                  return Card(key: ValueKey('ride-${ride['id']}'), child: ListTile(
                    title: Text('${ride['vehicle_type']} • ₦${ride['quoted_fare']}'),
                    subtitle: Text('${ride['pickup_address']} → ${ride['destination_address']}\nPickup ${wrapped['pickup_distance_km']} km away'),
                    isThreeLine: true,
                    trailing: IconButton(onPressed: _busy ? null : () => _acceptRide(wrapped), icon: const Icon(Icons.check_circle_outline)),
                  ));
                }),
                _section('Nearby parcel requests', _parcels, (wrapped) {
                  final parcel = Map<String, dynamic>.from(wrapped['parcel'] as Map);
                  return Card(key: ValueKey('parcel-${parcel['id']}'), child: ListTile(
                    title: Text('${parcel['package_size']} • ₦${parcel['quoted_fare']}'),
                    subtitle: Text('${parcel['pickup_address']} → ${parcel['destination_address']}\nPickup ${wrapped['pickup_distance_km']} km away'),
                    isThreeLine: true,
                    trailing: IconButton(onPressed: _busy ? null : () => _acceptParcel(wrapped), icon: const Icon(Icons.check_circle_outline)),
                  ));
                }),
              ],
              _section('My active rides', _myRides, (ride) {
                final status = ride['status']?.toString() ?? '';
                final next = status == 'DRIVER_ASSIGNED' ? 'Arriving' : status == 'DRIVER_ARRIVING' ? 'Start trip' : status == 'IN_PROGRESS' ? 'Complete trip' : '';
                return Card(key: ValueKey('myride-${ride['id']}'), child: ListTile(
                  title: Text('${ride['pickup_address']} → ${ride['destination_address']}'),
                  subtitle: Text(status),
                  trailing: next.isEmpty ? null : FilledButton(onPressed: _busy ? null : () => _rideStatus(ride), child: Text(next)),
                ));
              }),
              _section('My active parcels', _myParcels, (parcel) {
                final status = parcel['status']?.toString() ?? '';
                final next = status == 'DRIVER_ASSIGNED' ? 'Picked up' : status == 'PICKED_UP' ? 'In transit' : status == 'IN_TRANSIT' ? 'Delivered' : '';
                return Card(key: ValueKey('myparcel-${parcel['id']}'), child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('${parcel['package_description']} • ${parcel['quoted_fare']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${parcel['pickup_address']} → ${parcel['destination_address']}\n$status'),
                    if (status == 'IN_TRANSIT') TextField(controller: _deliveryCode, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Recipient delivery code')),
                    if (next.isNotEmpty) Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _busy ? null : () => _parcelStatus(parcel), child: Text(next))),
                  ]),
                ));
              }),
            ],
            if (_busy) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
