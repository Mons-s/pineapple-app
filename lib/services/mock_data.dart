import '../models/batch.dart';
import '../models/order.dart';
import '../models/delivery_address.dart';

class CartItem {
  final Batch batch;
  double quantityKg;
  CartItem(this.batch, this.quantityKg);
}

/// Temporary stand-in for Firestore so the app is tappable before a
/// Firebase project is connected. Swap each method here for a real
/// Firestore call later — the screens that use this don't need to change,
/// only this file does.
class MockData {
  // In-memory cart and selected delivery address for the demo flow.
  static CartItem? cart;
  static DeliveryAddress? selectedAddress;

  static List<Batch> batches = [
    Batch(
      id: 'batch_a',
      grade: 'A',
      pricePerKg: 60,
      stockKg: 235,
      harvestDate: DateTime(2026, 10, 30),
      certificateUrl: '',
      certificateIssuedBy: 'State Agri Testing Lab',
      certificateDate: DateTime(2026, 10, 29),
      brixSweetness: 14,
      status: 'active',
      ratingAvg: 4.6,
      ratingCount: 32,
    ),
    Batch(
      id: 'batch_b',
      grade: 'B',
      pricePerKg: 45,
      stockKg: 18,
      harvestDate: DateTime(2026, 10, 28),
      certificateUrl: '',
      certificateIssuedBy: 'State Agri Testing Lab',
      certificateDate: DateTime(2026, 10, 27),
      brixSweetness: 12,
      status: 'active',
      ratingAvg: 4.2,
      ratingCount: 11,
    ),
  ];

  static List<PineappleOrder> orders = [
    PineappleOrder(
      id: 'order_1051',
      buyerId: 'u1',
      buyerName: 'Priya',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 5,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 30,
      totalAmount: 330,
      addressLine: '12, Green Park, near temple',
      lat: 10.56,
      lng: 76.24,
      distanceKm: 4.2,
      deliverySlot: '9-12 am',
      status: 'out_for_delivery',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1052',
      buyerId: 'u2',
      buyerName: 'Arjun',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 8,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 30,
      totalAmount: 510,
      addressLine: '14 MG Road, near bus stop',
      lat: 10.58,
      lng: 76.27,
      distanceKm: 6.1,
      deliverySlot: '9-12 am',
      status: 'placed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
  ];
}
