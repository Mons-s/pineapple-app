import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/batch.dart';
import '../../services/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = MockData.orders;
    final batches = MockData.batches;

    final pendingCount = orders.where((o) => o.status == 'placed').length;
    final inTransitCount = orders.where((o) => o.status == 'out_for_delivery').length;
    final totalOrders = orders.length;
    final revenue = orders
        .where((o) => o.status != 'cancelled')
        .fold<double>(0, (sum, o) => sum + o.totalAmount);

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final now = DateTime.now();
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dashboard',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16281F))),
                    Text(dateStr,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded,
                            color: Color(0xFFE65100), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '$pendingCount order${pendingCount > 1 ? 's' : ''} waiting for confirmation',
                          style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                _MetricTile(
                  label: 'Total orders',
                  value: '$totalOrders',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF2F6B4F),
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Total revenue',
                  value: '₹${revenue.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFFD98F27),
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Pending confirmation',
                  value: '$pendingCount',
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFB25E1A),
                  urgent: pendingCount > 0,
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Out for delivery',
                  value: '$inTransitCount',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _RecentOrdersCard(orders: orders.take(5).toList()),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _StockCard(batches: batches),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool urgent;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: urgent
              ? Border.all(color: const Color(0xFFFFB74D), width: 1.5)
              : Border.all(color: const Color(0xFFE4DFD2)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (urgent)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE65100), shape: BoxShape.circle),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final List<PineappleOrder> orders;
  const _RecentOrdersCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16281F))),
                TextButton(
                    onPressed: () {},
                    child: const Text('View all',
                        style: TextStyle(color: Color(0xFF2F6B4F), fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF0EBE0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                _TH('Order', flex: 1),
                _TH('Buyer', flex: 2),
                _TH('Qty', flex: 1),
                _TH('Distance', flex: 1),
                _TH('Slot', flex: 1),
                _TH('Status', flex: 1),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0EBE0)),
          ...orders.map((o) => _OrderRow(order: o)),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  final int flex;
  const _TH(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A9690),
              letterSpacing: 0.5)),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final PineappleOrder order;
  const _OrderRow({required this.order});

  String _displayId(String id) {
    final parts = id.split('_');
    return parts.length > 1 ? '#${parts.last}' : id;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F3EE)))),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(_displayId(order.id),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16281F)))),
          Expanded(
              flex: 2,
              child: Text(order.buyerName,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text('${order.quantityKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text('${order.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text(order.deliverySlot,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5A7060)))),
          Expanded(flex: 1, child: _StatusChip(status: order.status)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'placed' => (l: 'Pending', bg: const Color(0xFFFFF3E0), fg: const Color(0xFFE65100)),
      'confirmed' => (l: 'Confirmed', bg: const Color(0xFFE3F0FB), fg: const Color(0xFF1565C0)),
      'out_for_delivery' => (l: 'In transit', bg: const Color(0xFFE3EEE7), fg: const Color(0xFF2F6B4F)),
      'delivered' => (l: 'Delivered', bg: const Color(0xFFF0EBE0), fg: const Color(0xFF5A7060)),
      'cancelled' => (l: 'Cancelled', bg: const Color(0xFFF6DCD6), fg: const Color(0xFFB23A2E)),
      _ => (l: status, bg: Colors.grey.shade100, fg: Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: config.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(config.l,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: config.fg)),
    );
  }
}

class _StockCard extends StatelessWidget {
  final List<Batch> batches;
  const _StockCard({required this.batches});

  @override
  Widget build(BuildContext context) {
    final lowBatches = batches.where((b) => b.stockKg < 30).toList();

    return Container(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('Stock Remaining',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16281F))),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF0EBE0)),
          ...batches.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _StockRow(batch: b),
              )),
          if (lowBatches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFE65100), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Grade ${lowBatches.map((b) => b.grade).join(', ')} stock is low. Consider restocking soon.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final Batch batch;
  const _StockRow({required this.batch});

  @override
  Widget build(BuildContext context) {
    final isLow = batch.stockKg < 30;
    final color = isLow ? const Color(0xFFB23A2E) : const Color(0xFF2F6B4F);
    final maxKg = batch.grade == 'A' ? 300.0 : 150.0;
    final label = batch.grade == 'A' ? 'Grade A · Premium' : 'Grade B · Standard';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16281F))),
              Row(
                children: [
                  Text('${batch.stockKg.toStringAsFixed(0)} kg',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                  if (isLow) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF6DCD6),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('low',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFB23A2E),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (batch.stockKg / maxKg).clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('₹${batch.pricePerKg.toStringAsFixed(0)}/kg',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A9690))),
        ],
      ),
    );
  }
}
