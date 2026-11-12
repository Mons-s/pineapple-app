import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/delivery_rules.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double distanceKm;
  const CheckoutScreen({super.key, required this.distanceKm});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedSlot = '9–12 am';

  static const _slots = ['9–12 am', '2–5 pm'];

  double get deliveryFee => DeliveryRules.deliveryFee(widget.distanceKm);
  double get subtotal {
    final cart = MockData.cart;
    if (cart == null) return 0;
    return cart.batch.pricePerKg * cart.quantityKg;
  }

  double get total => subtotal + deliveryFee;

  void _placeOrder() {
    final cart = MockData.cart;
    final address = MockData.selectedAddress;
    if (cart == null || address == null) return;

    final orderId = 'order_${1050 + MockData.orders.length + 1}';
    final order = PineappleOrder(
      id: orderId,
      buyerId: 'guest',
      buyerName: 'Guest',
      batchId: cart.batch.id,
      grade: cart.batch.grade,
      quantityKg: cart.quantityKg,
      pricePerKgSnapshot: cart.batch.pricePerKg,
      deliveryFeeSnapshot: deliveryFee,
      totalAmount: total,
      addressLine: address.addressLine,
      lat: address.lat,
      lng: address.lng,
      distanceKm: widget.distanceKm,
      deliverySlot: _selectedSlot,
      status: 'placed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    );

    MockData.orders.add(order);
    MockData.cart = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = MockData.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Delivery address'),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MockData.selectedAddress?.addressLine ?? 'Selected location',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text('${widget.distanceKm.toStringAsFixed(1)} km from farm',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Delivery slot'),
            _card(
              child: Row(
                children: _slots.map((slot) {
                  final selected = _selectedSlot == slot;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSlot = slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(right: slot == _slots.first ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? AppTheme.primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 18,
                                color: selected ? Colors.white : Colors.grey.shade500),
                            const SizedBox(height: 4),
                            Text(slot,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.grey.shade700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Order summary'),
            _card(
              child: Column(
                children: [
                  if (cart != null)
                    _row(
                      'Grade ${cart.batch.grade} pineapple',
                      '${cart.quantityKg.toStringAsFixed(0)} kg × ₹${cart.batch.pricePerKg.toStringAsFixed(0)}',
                      '₹${subtotal.toStringAsFixed(0)}',
                    ),
                  const Divider(height: 20),
                  _row(
                    'Delivery fee',
                    '${widget.distanceKm.toStringAsFixed(1)} km × ₹${DeliveryRules.ratePerKm.toStringAsFixed(0)}',
                    '₹${deliveryFee.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 20),
                  _row('Total', '', '₹${total.toStringAsFixed(0)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cart != null ? _placeOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Pay ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A7060))),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4DFD2)),
        ),
        child: child,
      );

  Widget _row(String label, String sub, String value, {bool bold = false}) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
                if (sub.isNotEmpty)
                  Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  color: bold ? AppTheme.primary : const Color(0xFF16281F))),
        ],
      );
}
