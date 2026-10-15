import 'dart:async';

import 'package:bokku_mart/core/constants/app_colors.dart';
import 'package:bokku_mart/core/location/location_service.dart';
import 'package:bokku_mart/core/network/api_endpoints.dart';
import 'package:bokku_mart/core/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MobilityScreen extends ConsumerStatefulWidget {
  const MobilityScreen({super.key});

  @override
  ConsumerState<MobilityScreen> createState() => _MobilityScreenState();
}

class _MobilityScreenState extends ConsumerState<MobilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupAddress = TextEditingController();
  final _pickupLat = TextEditingController();
  final _pickupLon = TextEditingController();
  final _destinationAddress = TextEditingController();
  final _destinationLat = TextEditingController();
  final _destinationLon = TextEditingController();
  final _packageDescription = TextEditingController();
  final _recipientName = TextEditingController();
  final _recipientPhone = TextEditingController();
  final _transactionId = TextEditingController();

  String _service = 'RIDE';
  String _vehicleType = 'CAR';
  String _packageSize = 'SMALL';
  String _paymentMethod = 'CASH';
  bool _busy = false;
  String? _error;
  Map<String, dynamic>? _quote;
  String? _activeServiceId;
  String? _deliveryCode;
  List<Map<String, dynamic>> _history = const [];
  Timer? _historyRefreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
    _historyRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted && !_busy) _refreshHistory();
    });
  }

  @override
  void dispose() {
    _historyRefreshTimer?.cancel();
    _pickupAddress.dispose();
    _pickupLat.dispose();
    _pickupLon.dispose();
    _destinationAddress.dispose();
    _destinationLat.dispose();
    _destinationLon.dispose();
    _packageDescription.dispose();
    _recipientName.dispose();
    _recipientPhone.dispose();
    _transactionId.dispose();
    super.dispose();
  }

  Map<String, dynamic> _payload() {
    final common = <String, dynamic>{
      'pickup_address': _pickupAddress.text.trim(),
      'pickup_latitude': _pickupLat.text.trim(),
      'pickup_longitude': _pickupLon.text.trim(),
      'destination_address': _destinationAddress.text.trim(),
      'destination_latitude': _destinationLat.text.trim(),
      'destination_longitude': _destinationLon.text.trim(),
    };
    if (_service == 'RIDE') {
      return {'vehicle_type': _vehicleType, ...common};
    }
    return {
      'package_size': _packageSize,
      'package_description': _packageDescription.text.trim(),
      'recipient_name': _recipientName.text.trim(),
      'recipient_phone': _recipientPhone.text.trim(),
      ...common,
    };
  }

  Future<void> _pickLocation({required bool pickup}) async {
    final latitudeController = pickup ? _pickupLat : _destinationLat;
    final longitudeController = pickup ? _pickupLon : _destinationLon;
    final result = await context.push<Map<String, dynamic>>(
      '/location-picker',
      extra: {
        'label': pickup ? 'Pickup' : 'Destination',
        'latitude': double.tryParse(latitudeController.text.trim()),
        'longitude': double.tryParse(longitudeController.text.trim()),
      },
    );
    if (result == null || !mounted) return;
    latitudeController.text = (result['latitude'] as num).toDouble().toStringAsFixed(7);
    longitudeController.text = (result['longitude'] as num).toDouble().toStringAsFixed(7);
    final addressController = pickup ? _pickupAddress : _destinationAddress;
    final address = result['address']?.toString();
    if (address != null && address.isNotEmpty) {
      addressController.text = address;
    } else if (addressController.text.trim().isEmpty) {
      addressController.text = 'Map-selected location';
    }
    setState(() { _quote = null; _error = null; });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final LocationResult location =
          await ref.read(locationServiceProvider).getCurrentLocation();
      _pickupLat.text = location.latitude.toStringAsFixed(7);
      _pickupLon.text = location.longitude.toStringAsFixed(7);
      if (_pickupAddress.text.trim().isEmpty) {
        _pickupAddress.text = 'Current location';
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _calculateQuote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _quote = null;
    });
    try {
      final path = _service == 'RIDE' ? ApiEndpoints.rideQuote : ApiEndpoints.parcelQuote;
      final response = await ref.read(dioClientProvider).dio.post(
        path,
        data: _payload(),
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      _quote = Map<String, dynamic>.from(body['data'] as Map);
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestService() async {
    if (!_formKey.currentState!.validate()) return;
    const redirectUrl = String.fromEnvironment('PAYMENT_REDIRECT_URL');
    if (_paymentMethod == 'ONLINE' && redirectUrl.isEmpty) {
      setState(() => _error = 'Configure PAYMENT_REDIRECT_URL at build time before using online payments.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _deliveryCode = null;
    });
    try {
      final path = _service == 'RIDE' ? ApiEndpoints.rides : ApiEndpoints.parcels;
      final response = await ref.read(dioClientProvider).dio.post(
        path,
        data: {..._payload(), 'payment_method': _paymentMethod},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);
      _activeServiceId = data['id']?.toString();
      _deliveryCode = data['delivery_code']?.toString();

      if (_paymentMethod == 'ONLINE' && _activeServiceId != null) {
        final paymentResponse = await ref.read(dioClientProvider).dio.post(
          ApiEndpoints.servicePaymentInitialize,
          data: {
            'service_type': _service,
            'service_id': _activeServiceId,
            'redirect_url': redirectUrl,
          },
        );
        final paymentData =
            Map<String, dynamic>.from(paymentResponse.data as Map);
        final checkoutUrl = paymentData['checkout_url']?.toString();
        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          throw StateError('The payment provider did not return a checkout URL.');
        }
        final launched = await launchUrl(
          Uri.parse(checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw StateError('Could not open the payment checkout link.');
        }
      }

      _quote = null;
      await _refreshHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _deliveryCode == null
                  ? 'Request created successfully.'
                  : 'Parcel requested. Share code $_deliveryCode with the recipient.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payExisting(String id) async {
    const redirectUrl = String.fromEnvironment('PAYMENT_REDIRECT_URL');
    if (redirectUrl.isEmpty) {
      setState(() => _error = 'Configure PAYMENT_REDIRECT_URL at build time before using online payments.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final response = await ref.read(dioClientProvider).dio.post(
        ApiEndpoints.servicePaymentInitialize,
        data: {'service_type': _service, 'service_id': id, 'redirect_url': redirectUrl},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final checkoutUrl = body['checkout_url']?.toString();
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw StateError('The payment provider did not return a checkout URL.');
      }
      final launched = await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      if (!launched) throw StateError('Could not open the payment checkout link.');
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyServicePayment() async {
    if (_transactionId.text.trim().isEmpty) {
      setState(() => _error = 'Enter the transaction ID returned by Flutterwave.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await ref.read(dioClientProvider).dio.post(
        ApiEndpoints.servicePaymentVerify,
        data: {'transaction_id': _transactionId.text.trim()},
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      if (body['verified'] != true) {
        throw StateError('The payment could not be verified as successful.');
      }
      _transactionId.clear();
      await _refreshHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verified successfully.')),
        );
      }
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshHistory() async {
    try {
      final path = _service == 'RIDE' ? ApiEndpoints.rides : ApiEndpoints.parcels;
      final response = await ref.read(dioClientProvider).dio.get(path);
      final body = Map<String, dynamic>.from(response.data as Map);
      final raw = body['results'] ?? body['data'] ?? const [];
      if (raw is List) {
        _history = raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
      if (mounted) setState(() {});
    } catch (_) {
      // A failed history refresh must not hide the quote/request form.
    }
  }

  Future<void> _cancel(String id) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final path = _service == 'RIDE' ? ApiEndpoints.rideCancel(id) : ApiEndpoints.parcelCancel(id);
      await ref.read(dioClientProvider).dio.post(path, data: const {});
      await _refreshHistory();
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    final dio = error;
    try {
      final response = (dio as dynamic).response;
      final data = response?.data;
      if (data is Map) {
        return (data['detail'] ?? data['message'] ?? data.values.first).toString();
      }
    } catch (_) {
      // Fall through to the exception text.
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _money(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return '₦${amount.toStringAsFixed(2)}';
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator ??
            (value) => value == null || value.trim().isEmpty
                ? 'Required'
                : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rides & Parcel Delivery'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'RIDE', label: Text('Ride'), icon: Icon(Icons.local_taxi_outlined)),
                ButtonSegment(value: 'PARCEL', label: Text('Send parcel'), icon: Icon(Icons.local_shipping_outlined)),
              ],
              selected: {_service},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() {
                        _service = selection.first;
                        _quote = null;
                        _history = const [];
                        _error = null;
                      });
                      _refreshHistory();
                    },
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_service == 'RIDE') ...[
                    const Text('Choose your ride', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _vehicleType,
                      items: const [
                        DropdownMenuItem(value: 'CAR', child: Text('Car')),
                        DropdownMenuItem(value: 'MOTORCYCLE', child: Text('Motorcycle')),
                      ],
                      onChanged: _busy ? null : (value) => setState(() => _vehicleType = value ?? 'CAR'),
                      decoration: const InputDecoration(labelText: 'Vehicle type'),
                    ),
                  ] else ...[
                    const Text('Parcel details', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _packageSize,
                      items: const [
                        DropdownMenuItem(value: 'DOCUMENT', child: Text('Document')),
                        DropdownMenuItem(value: 'SMALL', child: Text('Small package')),
                        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium package')),
                        DropdownMenuItem(value: 'LARGE', child: Text('Large package (car only)')),
                      ],
                      onChanged: _busy ? null : (value) => setState(() => _packageSize = value ?? 'SMALL'),
                      decoration: const InputDecoration(labelText: 'Package size'),
                    ),
                    const SizedBox(height: 12),
                    _field(_packageDescription, 'What are you sending?'),
                    _field(_recipientName, 'Recipient full name'),
                    _field(_recipientPhone, 'Recipient phone number', keyboard: TextInputType.phone),
                  ],
                  const SizedBox(height: 14),
                  const Text('Pickup', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _field(_pickupAddress, 'Pickup address'),
                  Row(
                    children: [
                      Expanded(child: _field(_pickupLat, 'Pickup latitude', keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_pickupLon, 'Pickup longitude', keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: _busy ? null : _useCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use current location'),
                        ),
                        TextButton.icon(
                          onPressed: _busy ? null : () => _pickLocation(pickup: true),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Choose pickup on map'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Destination', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _field(_destinationAddress, 'Destination address'),
                  Row(
                    children: [
                      Expanded(child: _field(_destinationLat, 'Destination latitude', keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                      const SizedBox(width: 10),
                      Expanded(child: _field(_destinationLon, 'Destination longitude', keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _busy ? null : () => _pickLocation(pickup: false),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Choose destination on map'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'CASH', child: Text('Pay cash')),
                      DropdownMenuItem(value: 'ONLINE', child: Text('Pay online (Flutterwave)')),
                    ],
                    onChanged: _busy ? null : (value) => setState(() => _paymentMethod = value ?? 'CASH'),
                    decoration: const InputDecoration(labelText: 'Payment method'),
                  ),
                  if (_quote != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated fare', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_money(_quote!['quoted_fare']), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
                          Text('${_quote!['estimated_distance_km'] ?? '—'} km estimated • actual road distance may differ', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _busy ? null : _calculateQuote,
                    child: const Text('Calculate fare'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _busy ? null : _requestService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _busy
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_service == 'RIDE' ? 'Request ride' : 'Request parcel pickup'),
                  ),
                ],
              ),
            ),
            if (_paymentMethod == 'ONLINE') ...[
              const SizedBox(height: 24),
              const Text('Verify a completed online payment', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _field(_transactionId, 'Flutterwave transaction ID'),
              OutlinedButton(
                onPressed: _busy ? null : _verifyServicePayment,
                child: const Text('Verify payment'),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Text('Your requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                IconButton(onPressed: _busy ? null : _refreshHistory, icon: const Icon(Icons.refresh)),
              ],
            ),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Your ride and parcel requests will appear here.'),
              )
            else
              ..._history.map((item) {
                final id = item['id']?.toString() ?? '';
                final statusValue = item['status']?.toString() ?? 'UNKNOWN';
                final canCancel = (_service == 'RIDE' && const {
                  'REQUESTED', 'SEARCHING', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING',
                }.contains(statusValue)) || (_service == 'PARCEL' && const {
                  'REQUESTED', 'DRIVER_ASSIGNED',
                }.contains(statusValue));
                final canPay = item['payment_method'] == 'ONLINE' &&
                    item['payment_status'] != 'PAID' &&
                    !const {'CANCELLED', 'NO_DRIVER', 'DELIVERED'}.contains(statusValue);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => context.push('/mobility/tracking', extra: {
                      'serviceType': _service,
                      'job': item,
                    }),
                    title: Text('${_service == 'RIDE' ? item['vehicle_type'] ?? 'Ride' : item['package_description'] ?? 'Parcel'} • ${_money(item['quoted_fare'])}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['pickup_address'] ?? ''} → ${item['destination_address'] ?? ''}\n$statusValue • ${item['payment_status'] ?? 'UNPAID'}'),
                        if (item['driver_name'] != null) Text('Driver: ${item['driver_name']}'),
                        if (item['driver_location'] != null) Text('Driver location: ${item['driver_location']['latitude']}, ${item['driver_location']['longitude']}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: (canCancel || canPay) && id.isNotEmpty
                        ? PopupMenuButton<String>(
                            enabled: !_busy,
                            onSelected: (action) {
                              if (action == 'pay') _payExisting(id);
                              if (action == 'cancel') _cancel(id);
                            },
                            itemBuilder: (context) => [
                              if (canPay) const PopupMenuItem(value: 'pay', child: Text('Pay online')),
                              if (canCancel) const PopupMenuItem(value: 'cancel', child: Text('Cancel request')),
                            ],
                          )
                        : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
