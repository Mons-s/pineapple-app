import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _orders = [
    {'id': '#1052', 'buyer': 'Arjun Kumar', 'phone': '9876543210', 'kg': 8.0, 'grade': 'A', 'dist': 6.1, 'slot': '9–12 am', 'status': 'pending', 'amount': 700},
    {'id': '#1051', 'buyer': 'Priya Nair', 'phone': '9845123456', 'kg': 5.0, 'grade': 'A', 'dist': 4.2, 'slot': '9–12 am', 'status': 'dispatched', 'amount': 446},
    {'id': '#1050', 'buyer': 'Rahul Menon', 'phone': '9745678901', 'kg': 10.0, 'grade': 'B', 'dist': 2.5, 'slot': '2–5 pm', 'status': 'delivered', 'amount': 563},
    {'id': '#1049', 'buyer': 'Sneha Thomas', 'phone': '9612345678', 'kg': 3.0, 'grade': 'B', 'dist': 7.8, 'slot': '2–5 pm', 'status': 'pending', 'amount': 204},
    {'id': '#1048', 'buyer': 'Anil George', 'phone': '9789012345', 'kg': 6.0, 'grade': 'A', 'dist': 3.1, 'slot': '9–12 am', 'status': 'delivered', 'amount': 525},
    {'id': '#1047', 'buyer': 'Meera Pillai', 'phone': '9654321098', 'kg': 4.0, 'grade': 'A', 'dist': 5.5, 'slot': '2–5 pm', 'status': 'pending', 'amount': 368},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _orders;
    final statusMap = {
      'Pending': 'pending',
      'Dispatched': 'dispatched',
      'Delivered': 'delivered',
    };
    return _orders.where((o) => o['status'] == statusMap[_filter]).toList();
  }

  void _advance(Map<String, dynamic> order) {
    setState(() {
      if (order['status'] == 'pending') order['status'] = 'dispatched';
      else if (order['status'] == 'dispatched') order['status'] = 'delivered';
    });
  }

  int _countByStatus(String status) =>
      _orders.where((o) => o['status'] == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text('Orders',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16281F))),
            const SizedBox(height: 4),
            Text('Manage and update order statuses',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 24),

            // Filter tabs
            Row(
              children: [
                _FilterTab(
                    label: 'All',
                    count: _orders.length,
                    selected: _filter == 'All',
                    onTap: () => setState(() => _filter = 'All')),
                const SizedBox(width: 8),
                _FilterTab(
                    label: 'Pending',
                    count: _countByStatus('pending'),
                    selected: _filter == 'Pending',
                    urgent: true,
                    onTap: () => setState(() => _filter = 'Pending')),
                const SizedBox(width: 8),
                _FilterTab(
                    label: 'Dispatched',
                    count: _countByStatus('dispatched'),
                    selected: _filter == 'Dispatched',
                    onTap: () => setState(() => _filter = 'Dispatched')),
                const SizedBox(width: 8),
                _FilterTab(
                    label: 'Delivered',
                    count: _countByStatus('delivered'),
                    selected: _filter == 'Delivered',
                    onTap: () => setState(() => _filter = 'Delivered')),
              ],
            ),
            const SizedBox(height: 20),

            // Table
            Expanded(
              child: Container(
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
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F7F3),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(14)),
                        border: Border(
                            bottom:
                                BorderSide(color: Color(0xFFE4DFD2))),
                      ),
                      child: Row(
                        children: const [
                          _TH('Order', flex: 1),
                          _TH('Buyer', flex: 2),
                          _TH('Qty · Grade', flex: 1),
                          _TH('Distance', flex: 1),
                          _TH('Slot', flex: 1),
                          _TH('Amount', flex: 1),
                          _TH('Status', flex: 1),
                          _TH('Action', flex: 2),
                        ],
                      ),
                    ),
                    // Rows
                    Expanded(
                      child: _filtered.isEmpty
                          ? const Center(
                              child: Text('No orders in this category',
                                  style: TextStyle(
                                      color: Color(0xFF8A9690), fontSize: 14)))
                          : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _OrderRow(
                                order: _filtered[i],
                                onAdvance: () => _advance(_filtered[i]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _OrderRow extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAdvance;
  const _OrderRow({required this.order, required this.onAdvance});

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final status = o['status'] as String;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFFAF8F4) : Colors.white,
          border: const Border(
              bottom: BorderSide(color: Color(0xFFF0EBE0))),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(o['id'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16281F)))),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o['buyer'],
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF16281F))),
                    Text(o['phone'],
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF8A9690))),
                  ],
                )),
            Expanded(
                flex: 1,
                child: Text(
                    '${o['kg'].toStringAsFixed(0)} kg · Grade ${o['grade']}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF16281F)))),
            Expanded(
                flex: 1,
                child: Text('${o['dist']} km',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF16281F)))),
            Expanded(
                flex: 1,
                child: Text(o['slot'],
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF5A7060)))),
            Expanded(
                flex: 1,
                child: Text('₹${o['amount']}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16281F),
                        fontFeatures: [FontFeature.tabularFigures()]))),
            Expanded(flex: 1, child: _StatusChip(status: status)),
            Expanded(
                flex: 2,
                child: status == 'delivered'
                    ? const Text('Completed',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF8A9690)))
                    : _ActionButton(
                        status: status,
                        onPressed: widget.onAdvance,
                      )),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String status;
  final VoidCallback onPressed;
  const _ActionButton({required this.status, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
          isPending ? Icons.check_circle_outline : Icons.local_shipping_rounded,
          size: 14),
      label: Text(isPending ? 'Confirm order' : 'Mark delivered',
          style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPending ? const Color(0xFF2F6B4F) : const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      'pending' => (l: 'Pending', bg: const Color(0xFFFFF3E0), fg: const Color(0xFFE65100)),
      'dispatched' => (l: 'Dispatched', bg: const Color(0xFFE3EEE7), fg: const Color(0xFF2F6B4F)),
      'delivered' => (l: 'Delivered', bg: const Color(0xFFF0EBE0), fg: const Color(0xFF5A7060)),
      _ => (l: status, bg: Colors.grey.shade100, fg: Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(cfg.l,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: cfg.fg)),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final bool urgent;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16281F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? const Color(0xFF16281F)
                  : const Color(0xFFE4DFD2)),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF5A7060))),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: urgent && !selected
                    ? const Color(0xFFE65100)
                    : selected
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFF0EBE0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: urgent && !selected
                          ? Colors.white
                          : selected
                              ? Colors.white
                              : const Color(0xFF5A7060))),
            ),
          ],
        ),
      ),
    );
  }
}
