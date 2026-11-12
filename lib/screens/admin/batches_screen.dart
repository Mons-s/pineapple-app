import 'package:flutter/material.dart';

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({super.key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  final List<Map<String, dynamic>> _batches = [
    {
      'id': 'B001',
      'grade': 'A',
      'label': 'Premium',
      'price': 85.0,
      'stock': 235.0,
      'brix': 16.0,
      'certBy': 'AgriTest Labs',
      'certDate': '28 Oct 2026',
      'status': 'active',
      'orders': 8,
    },
    {
      'id': 'B002',
      'grade': 'B',
      'label': 'Standard',
      'price': 55.0,
      'stock': 18.0,
      'brix': 13.0,
      'certBy': 'AgriTest Labs',
      'certDate': '28 Oct 2026',
      'status': 'active',
      'orders': 4,
    },
  ];

  void _showEditDialog(Map<String, dynamic> batch, String field) {
    final ctrl = TextEditingController(
        text: batch[field].toStringAsFixed(field == 'brix' ? 1 : 0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update ${field == 'price' ? 'Price' : 'Stock'} · Grade ${batch['grade']}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: field == 'price' ? 'Price per kg (₹)' : 'Stock in kg',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null) {
                setState(() => batch[field] = val);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6B4F),
                foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddBatchDialog() {
    final gradeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final brixCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Grade', border: OutlineInputBorder()),
              items: ['A', 'B'].map((g) => DropdownMenuItem(value: g, child: Text('Grade $g'))).toList(),
              onChanged: (v) => gradeCtrl.text = v ?? '',
            ),
            const SizedBox(height: 12),
            TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                    labelText: 'Price per kg (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(
                    labelText: 'Stock (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(
                controller: brixCtrl,
                decoration: const InputDecoration(
                    labelText: 'Brix sweetness (°)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _batches.add({
                  'id': 'B00${_batches.length + 1}',
                  'grade': gradeCtrl.text.isNotEmpty ? gradeCtrl.text : 'A',
                  'label': gradeCtrl.text == 'A' ? 'Premium' : 'Standard',
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'stock': double.tryParse(stockCtrl.text) ?? 0,
                  'brix': double.tryParse(brixCtrl.text) ?? 0,
                  'certBy': 'Pending',
                  'certDate': 'Not uploaded',
                  'status': 'active',
                  'orders': 0,
                });
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6B4F),
                foregroundColor: Colors.white),
            child: const Text('Add Batch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text('Batches',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16281F))),
                    Text('Manage stock, pricing, and certificates',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddBatchDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add batch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6B4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: _batches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _BatchCard(
                  batch: _batches[i],
                  onEditPrice: () => _showEditDialog(_batches[i], 'price'),
                  onUpdateStock: () => _showEditDialog(_batches[i], 'stock'),
                  onToggleStatus: () => setState(() {
                    _batches[i]['status'] =
                        _batches[i]['status'] == 'active' ? 'paused' : 'active';
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final VoidCallback onEditPrice;
  final VoidCallback onUpdateStock;
  final VoidCallback onToggleStatus;

  const _BatchCard({
    required this.batch,
    required this.onEditPrice,
    required this.onUpdateStock,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = batch['status'] == 'active';
    final isLow = (batch['stock'] as double) < 30;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isLow
                ? const Color(0xFFFFCC80)
                : const Color(0xFFE4DFD2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: batch['grade'] == 'A'
                  ? const Color(0xFF2F6B4F)
                  : const Color(0xFF5C8A6A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text('${batch['grade']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Grade ${batch['grade']} · ${batch['label']}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16281F))),
                    const SizedBox(width: 10),
                    _StatusPill(active: isActive),
                    if (isLow) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF6DCD6),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('Low stock',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB23A2E),
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                        icon: Icons.currency_rupee,
                        label: '₹${batch['price'].toStringAsFixed(0)}/kg'),
                    const SizedBox(width: 12),
                    _InfoChip(
                        icon: Icons.inventory_2_outlined,
                        label: '${batch['stock'].toStringAsFixed(0)} kg remaining'),
                    const SizedBox(width: 12),
                    _InfoChip(
                        icon: Icons.science_outlined,
                        label: 'Brix ${batch['brix']}°'),
                    const SizedBox(width: 12),
                    _InfoChip(
                        icon: Icons.receipt_long_outlined,
                        label: '${batch['orders']} orders'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 13, color: Color(0xFF2F6B4F)),
                    const SizedBox(width: 4),
                    Text('${batch['certBy']} · ${batch['certDate']}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5A7060))),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onEditPrice,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit price',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F6B4F),
                      side: const BorderSide(color: Color(0xFF2F6B4F)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onUpdateStock,
                    icon: const Icon(Icons.add_box_outlined, size: 14),
                    label: const Text('Update stock',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16281F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onToggleStatus,
                icon: Icon(
                    isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 14),
                label: Text(isActive ? 'Pause batch' : 'Activate batch',
                    style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: isActive
                      ? const Color(0xFFB23A2E)
                      : const Color(0xFF2F6B4F),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;
  const _StatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE3EEE7) : const Color(0xFFF0EBE0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xFF2F6B4F)
                  : const Color(0xFF8A9690),
            ),
          ),
          const SizedBox(width: 5),
          Text(active ? 'Active' : 'Paused',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? const Color(0xFF2F6B4F)
                      : const Color(0xFF8A9690))),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF5A7060)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF16281F))),
        ],
      ),
    );
  }
}
