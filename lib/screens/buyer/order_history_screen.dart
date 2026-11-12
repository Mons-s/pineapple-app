import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  void _cancelOrder(String orderId) {
    setState(() {
      final i = MockData.orders.indexWhere((o) => o.id == orderId);
      if (i != -1) {
        MockData.orders[i] = MockData.orders[i].copyWith(status: 'cancelled');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = MockData.orders.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F3EE),
      body: orders.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onCancel: orders[i].status == 'placed'
                    ? () => _cancelOrder(orders[i].id)
                    : null,
              ),
            ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final PineappleOrder order;
  final VoidCallback? onCancel;
  const _OrderCard({required this.order, this.onCancel});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  String _displayId(String id) {
    final parts = id.split('_');
    return '#${parts.length > 1 ? parts.last : id}';
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final cfg = _statusConfig(o.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFD2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(o.grade,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_displayId(o.id),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF16281F))),
                            const SizedBox(width: 8),
                            _StatusChip(status: o.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${o.quantityKg.toStringAsFixed(0)} kg · ₹${o.totalAmount.toStringAsFixed(0)} · ${o.deliverySlot}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          // Status progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StatusTracker(status: o.status),
          ),
          const SizedBox(height: 4),

          // Expanded detail
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFF0EBE0)),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Grade', value: 'Grade ${o.grade} pineapple'),
                  _DetailRow(label: 'Quantity', value: '${o.quantityKg.toStringAsFixed(0)} kg'),
                  _DetailRow(
                      label: 'Price',
                      value: '₹${o.pricePerKgSnapshot.toStringAsFixed(0)}/kg × ${o.quantityKg.toStringAsFixed(0)} kg'),
                  _DetailRow(
                      label: 'Delivery fee',
                      value: '₹${o.deliveryFeeSnapshot.toStringAsFixed(0)} (${o.distanceKm.toStringAsFixed(1)} km)'),
                  _DetailRow(label: 'Total', value: '₹${o.totalAmount.toStringAsFixed(0)}', bold: true),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF0EBE0)),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Delivery address', value: o.addressLine),
                  _DetailRow(label: 'Slot', value: o.deliverySlot),
                  _DetailRow(label: 'Payment', value: 'Cash on delivery'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Cancel button for placed orders
          if (widget.onCancel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB23A2E),
                    side: const BorderSide(color: Color(0xFFB23A2E)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text('This cannot be undone. The order will be marked as cancelled.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep order')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB23A2E),
                foregroundColor: Colors.white),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _statusConfig(String status) => switch (status) {
        'placed' => {'label': 'Pending', 'color': const Color(0xFFE65100)},
        'confirmed' => {'label': 'Confirmed', 'color': const Color(0xFF1565C0)},
        'out_for_delivery' => {'label': 'Out for delivery', 'color': AppTheme.primary},
        'delivered' => {'label': 'Delivered', 'color': AppTheme.success},
        _ => {'label': 'Cancelled', 'color': const Color(0xFFB23A2E)},
      };
}

class _StatusTracker extends StatelessWidget {
  final String status;
  const _StatusTracker({required this.status});

  static const _steps = ['placed', 'confirmed', 'out_for_delivery', 'delivered'];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFB23A2E)),
            const SizedBox(width: 6),
            Text('Order cancelled',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    final currentStep = _steps.indexOf(status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppTheme.primary : const Color(0xFFE4DFD2),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final done = currentStep >= stepIndex;
          final labels = ['Placed', 'Confirmed', 'Dispatched', 'Delivered'];
          return Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppTheme.primary : const Color(0xFFE4DFD2),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[stepIndex],
                  style: TextStyle(
                      fontSize: 10,
                      color: done ? AppTheme.primary : Colors.grey.shade400,
                      fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
            ],
          );
        }),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = switch (status) {
      'placed' => (l: 'Pending', bg: const Color(0xFFFFF3E0), fg: const Color(0xFFE65100)),
      'confirmed' => (l: 'Confirmed', bg: const Color(0xFFE3F0FB), fg: const Color(0xFF1565C0)),
      'out_for_delivery' => (l: 'On the way', bg: const Color(0xFFE3EEE7), fg: AppTheme.primary),
      'delivered' => (l: 'Delivered', bg: const Color(0xFFE3EEE7), fg: AppTheme.success),
      'cancelled' => (l: 'Cancelled', bg: const Color(0xFFF6DCD6), fg: const Color(0xFFB23A2E)),
      _ => (l: status, bg: Colors.grey.shade100, fg: Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(cfg.l,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cfg.fg)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF16281F),
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Your placed orders will appear here.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
