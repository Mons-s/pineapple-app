import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                    Text('Wednesday, 12 November 2026',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                _AlertBanner(),
              ],
            ),
            const SizedBox(height: 28),

            // Metric tiles
            Row(
              children: [
                _MetricTile(
                  label: 'Orders today',
                  value: '12',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF2F6B4F),
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Revenue today',
                  value: '₹4,120',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFFD98F27),
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Pending confirmation',
                  value: '3',
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFB25E1A),
                  urgent: true,
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  label: 'Out for delivery',
                  value: '5',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Orders + Stock side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent orders
                Expanded(
                  flex: 3,
                  child: _RecentOrdersCard(),
                ),
                const SizedBox(width: 20),
                // Stock overview
                Expanded(
                  flex: 2,
                  child: _StockCard(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFFB74D)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.notifications_active_rounded,
              color: Color(0xFFE65100), size: 16),
          SizedBox(width: 8),
          Text('3 new orders waiting for confirmation',
              style: TextStyle(
                  color: Color(0xFFE65100),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
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
  final _orders = const [
    {'id': '#1052', 'buyer': 'Arjun Kumar', 'kg': '8 kg', 'dist': '6.1 km', 'slot': '9–12 am', 'status': 'pending'},
    {'id': '#1051', 'buyer': 'Priya Nair', 'kg': '5 kg', 'dist': '4.2 km', 'slot': '9–12 am', 'status': 'dispatched'},
    {'id': '#1050', 'buyer': 'Rahul Menon', 'kg': '10 kg', 'dist': '2.5 km', 'slot': '2–5 pm', 'status': 'delivered'},
    {'id': '#1049', 'buyer': 'Sneha Thomas', 'kg': '3 kg', 'dist': '7.8 km', 'slot': '2–5 pm', 'status': 'pending'},
    {'id': '#1048', 'buyer': 'Anil George', 'kg': '6 kg', 'dist': '3.1 km', 'slot': '9–12 am', 'status': 'delivered'},
  ];

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
                        style: TextStyle(
                            color: Color(0xFF2F6B4F), fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF0EBE0)),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                _tableHeader('Order', flex: 1),
                _tableHeader('Buyer', flex: 2),
                _tableHeader('Qty', flex: 1),
                _tableHeader('Distance', flex: 1),
                _tableHeader('Slot', flex: 1),
                _tableHeader('Status', flex: 1),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0EBE0)),
          ..._orders.map((o) => _OrderRow(order: o)),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {required int flex}) {
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
  final Map<String, String> order;
  const _OrderRow({required this.order});

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
              child: Text(order['id']!,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16281F)))),
          Expanded(
              flex: 2,
              child: Text(order['buyer']!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text(order['kg']!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text(order['dist']!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F)))),
          Expanded(
              flex: 1,
              child: Text(order['slot']!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A7060)))),
          Expanded(flex: 1, child: _StatusChip(status: order['status']!)),
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
      'pending' => (
          label: 'Pending',
          bg: const Color(0xFFFFF3E0),
          fg: const Color(0xFFE65100)
        ),
      'dispatched' => (
          label: 'Dispatched',
          bg: const Color(0xFFE3EEE7),
          fg: const Color(0xFF2F6B4F)
        ),
      'delivered' => (
          label: 'Delivered',
          bg: const Color(0xFFF0EBE0),
          fg: const Color(0xFF5A7060)
        ),
      _ => (label: status, bg: Colors.grey.shade100, fg: Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: config.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(config.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: config.fg)),
    );
  }
}

class _StockCard extends StatelessWidget {
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('Stock Remaining',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16281F))),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF0EBE0)),
          _StockRow(
            grade: 'Grade A · Premium',
            kg: 235,
            maxKg: 300,
            price: '₹85/kg',
            color: const Color(0xFF2F6B4F),
            low: false,
          ),
          const SizedBox(height: 16),
          _StockRow(
            grade: 'Grade B · Standard',
            kg: 18,
            maxKg: 150,
            price: '₹55/kg',
            color: const Color(0xFFB23A2E),
            low: true,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE65100), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Grade B stock is low. Consider restocking soon.',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final String grade;
  final int kg;
  final int maxKg;
  final String price;
  final Color color;
  final bool low;

  const _StockRow({
    required this.grade,
    required this.kg,
    required this.maxKg,
    required this.price,
    required this.color,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(grade,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16281F))),
              Row(
                children: [
                  Text('$kg kg',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (low) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
              value: kg / maxKg,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(price,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A9690))),
        ],
      ),
    );
  }
}
