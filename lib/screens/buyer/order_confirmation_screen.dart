import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final PineappleOrder order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Success icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 52),
              ),
              const SizedBox(height: 20),
              const Text('Order placed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Order ${_displayId(order.id)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // Summary card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardTitle('Order summary'),
                    const SizedBox(height: 12),
                    _row('Grade ${order.grade} pineapple',
                        '${order.quantityKg.toStringAsFixed(0)} kg × ₹${order.pricePerKgSnapshot.toStringAsFixed(0)}',
                        '₹${(order.quantityKg * order.pricePerKgSnapshot).toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _row('Delivery fee', '${order.distanceKm.toStringAsFixed(1)} km',
                        '₹${order.deliveryFeeSnapshot.toStringAsFixed(0)}'),
                    const Divider(height: 20),
                    _row('Total', '', '₹${order.totalAmount.toStringAsFixed(0)}',
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Delivery details card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardTitle('Delivery details'),
                    const SizedBox(height: 12),
                    _detail(Icons.location_on_rounded, order.addressLine),
                    const SizedBox(height: 10),
                    _detail(Icons.access_time_rounded, 'Slot: ${order.deliverySlot}'),
                    const SizedBox(height: 10),
                    _detail(Icons.payment_rounded, 'Payment on delivery'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFFE65100), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your order is pending confirmation from the farm. You\'ll be notified once it\'s confirmed.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Back to home
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayId(String id) {
    final parts = id.split('_');
    return parts.length > 1 ? '#${parts.last}' : id;
  }

  Widget _cardTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF16281F)));

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

  Widget _detail(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ),
        ],
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4DFD2)),
      ),
      child: child,
    );
  }
}
