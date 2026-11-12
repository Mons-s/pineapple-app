import 'package:flutter/material.dart';
import '../../models/batch.dart';
import '../../services/delivery_rules.dart';
import '../../services/mock_data.dart';
import '../../theme.dart';
import 'location_picker_screen.dart';

class BatchDetailScreen extends StatefulWidget {
  final Batch batch;
  const BatchDetailScreen({super.key, required this.batch});

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  double _quantity = DeliveryRules.minOrderKg;

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final subtotal = batch.pricePerKg * _quantity;

    return Scaffold(
      appBar: AppBar(title: Text('Grade ${batch.grade}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.eco, size: 48, color: AppTheme.accent)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${batch.pricePerKg.toStringAsFixed(0)} / kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              Text('★ ${batch.ratingAvg} · ${batch.ratingCount} reviews', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.success.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.verified, color: AppTheme.success, size: 18),
                    SizedBox(width: 6),
                    Text('Quality tested', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  Text('Sweetness ${batch.brixSweetness.toStringAsFixed(0)}° Brix · No pesticide residue',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  Text('Lab: ${batch.certificateIssuedBy}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text('View certificate (PDF)', style: TextStyle(color: AppTheme.success, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity (kg)', style: TextStyle(fontWeight: FontWeight.w500)),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > DeliveryRules.minOrderKg ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(_quantity.toStringAsFixed(0), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    onPressed: _quantity < batch.stockKg ? () => setState(() => _quantity++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          Text('Minimum order ${DeliveryRules.minOrderKg.toStringAsFixed(0)} kg', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: Colors.grey.shade600)),
              Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              MockData.cart = CartItem(batch, _quantity);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationPickerScreen()));
            },
            child: const Text('Add to cart & continue'),
          ),
        ),
      ),
    );
  }
}
