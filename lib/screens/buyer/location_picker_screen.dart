import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/delivery_address.dart';
import '../../services/delivery_rules.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';
import 'checkout_screen.dart';

/// NOTE: this screen uses GPS + the Haversine formula for the on-device
/// preview, not a Google Map widget yet — that needs a Maps API key
/// wired into AndroidManifest.xml/Info.plist first. Swap the circle
/// preview below for a GoogleMap widget once that key is in place; the
/// distance/radius logic (DeliveryRules) stays the same either way.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  double? _lat;
  double? _lng;
  bool _loading = false;
  String? _error;
  final _addressController = TextEditingController(text: '12, Green Park, near temple');

  Future<void> _useGps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
          setState(() {
            _error = 'Location permission denied. Please allow it in settings.';
            _loading = false;
          });
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not get your location. ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = _lat != null && _lng != null;
    final distance = hasPin ? DeliveryRules.distanceKm(_lat!, _lng!) : null;
    final within = distance != null && distance <= DeliveryRules.radiusKm;

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _RadiusPainter(within: hasPin ? within : null),
              child: Center(
                child: hasPin
                    ? Text(within ? 'Pin placed — within range' : 'Pin placed — outside range',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
                    : Text('Tap "Use GPS" to drop your pin', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
            ),
          if (hasPin)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (within ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    within ? '${distance!.toStringAsFixed(1)} km away' : '${distance!.toStringAsFixed(1)} km away — outside our area',
                    style: TextStyle(color: within ? AppTheme.success : AppTheme.danger, fontWeight: FontWeight.w600),
                  ),
                  if (within) Text('Delivery ₹${DeliveryRules.deliveryFee(distance).toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.success)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _useGps,
            icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
            label: Text(_loading ? 'Getting location…' : 'Use GPS'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: within
                ? () {
                    MockData.selectedAddress = DeliveryAddress(
                      id: 'addr_temp',
                      label: 'Delivery address',
                      addressLine: _addressController.text,
                      lat: _lat!,
                      lng: _lng!,
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(distanceKm: distance!)));
                  }
                : null,
            child: const Text('Confirm location'),
          ),
        ),
      ),
    );
  }
}

class _RadiusPainter extends CustomPainter {
  final bool? within;
  _RadiusPainter({this.within});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 - 10;
    final circlePaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius, borderPaint);

    final farmPaint = Paint()..color = AppTheme.accent;
    canvas.drawCircle(center, 5, farmPaint);

    if (within != null) {
      final pinPaint = Paint()..color = within! ? AppTheme.success : AppTheme.danger;
      canvas.drawCircle(center.translate(radius * 0.5, -radius * 0.4), 6, pinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadiusPainter oldDelegate) => oldDelegate.within != within;
}
