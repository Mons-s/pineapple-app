import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order.dart';
import '../../services/app_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'All';

  static const _filters = ['All', 'Pending', 'Confirmed', 'Out for delivery', 'Delivered'];

  List<PineappleOrder> _getFiltered(List<PineappleOrder> orders) => switch (_filter) {
        'Pending' => orders.where((o) => o.status == 'placed').toList(),
        'Confirmed' => orders.where((o) => o.status == 'confirmed').toList(),
        'Out for delivery' => orders.where((o) => o.status == 'out_for_delivery').toList(),
        'Delivered' => orders.where((o) => o.status == 'delivered').toList(),
        _ => orders,
      };

  int _getCount(List<PineappleOrder> orders, String filter) => switch (filter) {
        'All' => orders.length,
        'Pending' => orders.where((o) => o.status == 'placed').length,
        'Confirmed' => orders.where((o) => o.status == 'confirmed').length,
        'Out for delivery' => orders.where((o) => o.status == 'out_for_delivery').length,
        'Delivered' => orders.where((o) => o.status == 'delivered').length,
        _ => 0,
      };

  void _updateStatus(String orderId, String newStatus) {
    context.read<AppState>().updateOrderStatus(orderId, newStatus);
  }

  Future<void> _exportPackingList(List<PineappleOrder> allOrders) async {
    final active = allOrders
        .where((o) => o.status == 'placed' || o.status == 'confirmed' || o.status == 'out_for_delivery')
        .toList();

    if (active.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active orders to export.')),
        );
      }
      return;
    }

    // Group by delivery slot
    final Map<String, List<PineappleOrder>> bySlot = {};
    for (final o in active) {
      (bySlot[o.deliverySlot] ??= []).add(o);
    }

    final now = DateTime.now();
    final dateStr = DateFormat('d MMM yyyy').format(now);
    final fileDate = DateFormat('yyyyMMdd').format(now);
    final buf = StringBuffer();

    buf.writeln('FreshPine — Packing List');
    buf.writeln(dateStr);
    buf.writeln('═' * 52);
    buf.writeln();

    int totalOrders = 0;
    double totalKg = 0;

    for (final slot in bySlot.keys.toList()..sort()) {
      final orders = bySlot[slot]!;
      final slotKg = orders.fold<double>(0, (s, o) => s + o.quantityKg);
      totalOrders += orders.length;
      totalKg += slotKg;

      buf.writeln('SLOT: $slot  (${orders.length} order${orders.length > 1 ? 's' : ''}, ${slotKg.toStringAsFixed(1)} kg)');
      buf.writeln('─' * 52);

      for (final o in orders) {
        final id = o.id.split('_').last;
        final addr = o.addressLine.isNotEmpty ? o.addressLine : '—';
        buf.writeln('  #$id  ${o.buyerName.padRight(20)}  ${o.quantityKg.toStringAsFixed(1)} kg Grade ${o.grade}');
        buf.writeln('         $addr');
      }
      buf.writeln();
    }

    buf.writeln('═' * 52);
    buf.writeln('TOTAL: $totalOrders order${totalOrders > 1 ? 's' : ''}, ${totalKg.toStringAsFixed(1)} kg');

    final docs = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
    final path = '$docs\\Documents\\freshpine_packing_$fileDate.txt';
    await File(path).writeAsString(buf.toString());
    await launchUrl(Uri.file(path));
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    final filtered = _getFiltered(orders);
    final pendingCount = _getCount(orders, 'Pending');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: Padding(
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
                    const Text('Orders',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16281F))),
                    const SizedBox(height: 4),
                    Text('Manage and update order statuses',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  children: [
                    if (pendingCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                            Text('$pendingCount order${pendingCount > 1 ? 's' : ''} waiting for confirmation',
                                style: const TextStyle(
                                    color: Color(0xFFE65100),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _exportPackingList(orders),
                      icon: const Icon(Icons.print_rounded, size: 15),
                      label: const Text('Packing list'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2F6B4F),
                        side: const BorderSide(color: Color(0xFFB5CCBA)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isFirst = f == _filters.first;
                  return Padding(
                    padding: EdgeInsets.only(right: isFirst ? 0 : 0, left: isFirst ? 0 : 8),
                    child: _FilterTab(
                      label: f,
                      count: _getCount(orders, f),
                      selected: _filter == f,
                      urgent: f == 'Pending' && _getCount(orders, 'Pending') > 0,
                      onTap: () => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F7F3),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        border: Border(bottom: BorderSide(color: Color(0xFFE4DFD2))),
                      ),
                      child: const Row(
                        children: [
                          _TH('Order', flex: 1),
                          _TH('Buyer', flex: 2),
                          _TH('Qty · Grade', flex: 1),
                          _TH('Location · Slot', flex: 3),
                          _TH('Amount', flex: 1),
                          _TH('Status', flex: 2),
                          _TH('Action', flex: 3),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('No orders in this category',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _OrderRow(
                                order: filtered[i],
                                onUpdateStatus: (newStatus) =>
                                    _updateStatus(filtered[i].id, newStatus),
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
  final PineappleOrder order;
  final void Function(String newStatus) onUpdateStatus;
  const _OrderRow({required this.order, required this.onUpdateStatus});

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFFAF8F4) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFF0EBE0))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(_displayId(o.id),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16281F))),
            ),
            Expanded(
              flex: 2,
              child: Text(o.buyerName,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF16281F))),
            ),
            Expanded(
              flex: 1,
              child: Text('${o.quantityKg.toStringAsFixed(0)} kg · Grade ${o.grade}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF16281F))),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.addressLine.isNotEmpty ? o.addressLine : '—',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF16281F)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${o.distanceKm.toStringAsFixed(1)} km · ${o.deliverySlot}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A9690)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text('₹${o.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16281F),
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
            Expanded(flex: 2, child: _StatusChip(status: o.status)),
            Expanded(
              flex: 3,
              child: _ActionCell(
                status: o.status,
                onUpdateStatus: widget.onUpdateStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayId(String id) {
    final parts = id.split('_');
    return parts.length > 1 ? '#${parts.last}' : id;
  }
}

class _ActionCell extends StatelessWidget {
  final String status;
  final void Function(String) onUpdateStatus;
  const _ActionCell({required this.status, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'placed' => Row(
          children: [
            _ActionBtn(
              label: 'Confirm',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF2F6B4F),
              onPressed: () => onUpdateStatus('confirmed'),
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              label: 'Cancel',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFB23A2E),
              onPressed: () => onUpdateStatus('cancelled'),
              outlined: true,
            ),
          ],
        ),
      'confirmed' => Row(
          children: [
            _ActionBtn(
              label: 'Dispatch',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF1565C0),
              onPressed: () => onUpdateStatus('out_for_delivery'),
            ),
            const SizedBox(width: 8),
            _ActionBtn(
              label: 'Cancel',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFB23A2E),
              onPressed: () => onUpdateStatus('cancelled'),
              outlined: true,
            ),
          ],
        ),
      'out_for_delivery' => _ActionBtn(
          label: 'Mark delivered',
          icon: Icons.done_all_rounded,
          color: const Color(0xFF2F6B4F),
          onPressed: () => onUpdateStatus('delivered'),
        ),
      'delivered' => const Text('Completed',
          style: TextStyle(fontSize: 12, color: Color(0xFF8A9690))),
      'cancelled' => const Text('Cancelled',
          style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB23A2E),
              fontWeight: FontWeight.w500)),
      _ => const SizedBox.shrink(),
    };
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );

    return outlined
        ? OutlinedButton(onPressed: onPressed, style: style, child: child)
        : ElevatedButton(onPressed: onPressed, style: style, child: child);
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
      'out_for_delivery' => (l: 'Out for delivery', bg: const Color(0xFFE8F0FE), fg: const Color(0xFF1A73E8)),
      'delivered' => (l: 'Delivered', bg: const Color(0xFFF0EBE0), fg: const Color(0xFF5A7060)),
      'cancelled' => (l: 'Cancelled', bg: const Color(0xFFF6DCD6), fg: const Color(0xFFB23A2E)),
      _ => (l: status, bg: Colors.grey.shade100, fg: Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(cfg.l,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cfg.fg)),
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
              color: selected ? const Color(0xFF16281F) : const Color(0xFFE4DFD2)),
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
