import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/delivery_rules.dart';
import '../../services/mock_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _radiusCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _radiusCtrl = TextEditingController(text: DeliveryRules.radiusKm.toStringAsFixed(0));
    _rateCtrl = TextEditingController(text: DeliveryRules.ratePerKm.toStringAsFixed(0));
    _minOrderCtrl = TextEditingController(text: DeliveryRules.minOrderKg.toStringAsFixed(0));
    _latCtrl = TextEditingController(text: DeliveryRules.vendorLat.toString());
    _lngCtrl = TextEditingController(text: DeliveryRules.vendorLng.toString());
  }

  void _save() {
    final radius = double.tryParse(_radiusCtrl.text);
    final rate = double.tryParse(_rateCtrl.text);
    final minOrder = double.tryParse(_minOrderCtrl.text);
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (radius != null) DeliveryRules.radiusKm = radius;
    if (rate != null) DeliveryRules.ratePerKm = rate;
    if (minOrder != null) DeliveryRules.minOrderKg = minOrder;
    if (lat != null) DeliveryRules.vendorLat = lat;
    if (lng != null) DeliveryRules.vendorLng = lng;
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2),
        () => setState(() => _saved = false));
  }

  void _removeSlot(int i) => setState(() => MockData.deliverySlots.removeAt(i));

  void _addSlot() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add delivery slot'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Slot label',
            hintText: 'e.g. 6–9 pm',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final label = ctrl.text.trim();
              if (label.isNotEmpty) {
                setState(() => MockData.deliverySlots.add(label));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6B4F), foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _radiusCtrl.dispose();
    _rateCtrl.dispose();
    _minOrderCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16281F))),
            Text('Delivery rules and configuration',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 32),

            // Delivery rules card
            _Card(
              title: 'Delivery Rules',
              subtitle: 'These values are enforced server-side. Buyers cannot bypass them.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Service radius (km)',
                          hint: 'e.g. 10',
                          controller: _radiusCtrl,
                          icon: Icons.radar_rounded,
                          helper:
                              'Orders beyond this distance are rejected automatically.',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _Field(
                          label: 'Delivery fee (₹ per km)',
                          hint: 'e.g. 5',
                          controller: _rateCtrl,
                          icon: Icons.currency_rupee_rounded,
                          helper: 'Charged on top of product price.',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _Field(
                          label: 'Minimum order (kg)',
                          hint: 'e.g. 3',
                          controller: _minOrderCtrl,
                          icon: Icons.scale_rounded,
                          helper: 'Buyers cannot order less than this.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3EEE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 15, color: Color(0xFF2F6B4F)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The radius check runs on the server (Cloud Function). Even if someone modifies the app, they cannot place an order outside your service area.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF2F6B4F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Delivery slots card
            _Card(
              title: 'Delivery Slots',
              subtitle: 'Time windows buyers can choose when placing an order.',
              child: Column(
                children: [
                  ...MockData.deliverySlots.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFE4DFD2)),
                              ),
                              child: Text(
                                  e.value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF16281F))),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: MockData.deliverySlots.length > 1
                                  ? () => _removeSlot(e.key)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 18),
                              color: const Color(0xFFB23A2E),
                              tooltip: 'Remove slot',
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add slot'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2F6B4F)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Farm location card
            _Card(
              title: 'Farm / Vendor Location',
              subtitle: 'The centre point from which the delivery radius is measured.',
              child: Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: 'Latitude',
                      hint: 'e.g. 10.5276',
                      controller: _latCtrl,
                      icon: Icons.location_on_outlined,
                      helper: 'GPS coordinate of your farm.',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _Field(
                      label: 'Longitude',
                      hint: 'e.g. 76.2144',
                      controller: _lngCtrl,
                      icon: Icons.location_on_outlined,
                      helper: 'GPS coordinate of your farm.',
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Save button
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16281F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Save settings',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
                AnimatedOpacity(
                  opacity: _saved ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF2F6B4F), size: 18),
                      SizedBox(width: 6),
                      Text('Settings saved',
                          style: TextStyle(
                              color: Color(0xFF2F6B4F),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Card(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFD2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16281F))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String helper;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16281F))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF5A7060)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4DFD2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4DFD2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF2F6B4F), width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFFAF8F4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 4),
        Text(helper,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
