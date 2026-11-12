import 'package:flutter/material.dart';
import '../../models/batch.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';
import 'batch_detail_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batches = MockData.batches;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresh pineapples'),
        actions: [
          Builder(
            builder: (ctx) {
              final pendingCount = MockData.orders
                  .where((o) => o.status != 'cancelled' && o.status != 'delivered')
                  .length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: 'My orders',
                    onPressed: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                    ),
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB23A2E),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$pendingCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: batches.length,
        itemBuilder: (context, i) {
          final batch = batches[i];
          return _BatchCard(batch: batch);
        },
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Batch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: batch)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco, color: AppTheme.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Grade ${batch.grade}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(width: 8),
                        if (batch.isAvailable)
                          const _Pill(text: 'Certified', color: AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('₹${batch.pricePerKg.toStringAsFixed(0)} / kg · ${batch.stockKg.toStringAsFixed(0)} kg left',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
