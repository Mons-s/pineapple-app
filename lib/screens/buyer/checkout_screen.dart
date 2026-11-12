import 'package:flutter/material.dart';
import '../../services/delivery_rules.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';

class CheckoutScreen extends StatelessWidget {
  final double distanceKm;

  const CheckoutScreen({super.key, required this.distanceKm});

  double get deliveryFee => DeliveryRules.deliveryFee(distanceKm);
  double get subtotal {
    final cart = MockData.cart;
    if (cart == null) return 0;
    return cart.batch.pricePerKg * cart.quantityKg;
  }

  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
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
                  Text('${distanceKm.toStringAsFixed(1)} km from farm',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Order summary'),
            _card(
              child: Builder(builder: (context) {
                final cart = MockData.cart;
                final grade = cart != null ? 'Grade ${cart.batch.grade} pineapple' : 'Pineapple';
                final qtyLine = cart != null
                    ? '${cart.quantityKg.toStringAsFixed(0)} kg × ₹${cart.batch.pricePerKg.toStringAsFixed(0)}'
                    : '';
                return Column(
                  children: [
                    _row(grade, qtyLine, '₹${subtotal.toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _row('Delivery fee',
                        '${distanceKm.toStringAsFixed(1)} km × ₹${DeliveryRules.ratePerKm.toStringAsFixed(0)}',
                        '₹${deliveryFee.toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _row('Total', '', '₹${total.toStringAsFixed(0)}',
                        bold: true),
                  ],
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Payment coming soon — Razorpay integration pending'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Pay ₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A7060))),
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

  Widget _row(String label, String sub, String value, {bool bold = false}) =>
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            bold ? FontWeight.w700 : FontWeight.normal)),
                if (sub.isNotEmpty)
                  Text(sub,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
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
