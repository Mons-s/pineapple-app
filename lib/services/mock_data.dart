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

  static List<String> deliverySlots = ['9–12 am', '2–5 pm'];

  static List<PineappleOrder> orders = [
    PineappleOrder(
      id: 'order_1052',
      buyerId: 'u2',
      buyerName: 'Arjun Kumar',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 8,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 31,
      totalAmount: 511,
      addressLine: '14 MG Road, near bus stop',
      lat: 10.582,
      lng: 76.273,
      distanceKm: 6.1,
      deliverySlot: '9–12 am',
      status: 'placed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1051',
      buyerId: 'u1',
      buyerName: 'Priya Nair',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 5,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 21,
      totalAmount: 321,
      addressLine: '12, Green Park, near temple',
      lat: 10.560,
      lng: 76.241,
      distanceKm: 4.2,
      deliverySlot: '9–12 am',
      status: 'out_for_delivery',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1050',
      buyerId: 'u3',
      buyerName: 'Rahul Menon',
      batchId: 'batch_b',
      grade: 'B',
      quantityKg: 10,
      pricePerKgSnapshot: 45,
      deliveryFeeSnapshot: 13,
      totalAmount: 463,
      addressLine: '5, River View Colony',
      lat: 10.541,
      lng: 76.228,
      distanceKm: 2.5,
      deliverySlot: '2–5 pm',
      status: 'delivered',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1049',
      buyerId: 'u4',
      buyerName: 'Sneha Thomas',
      batchId: 'batch_b',
      grade: 'B',
      quantityKg: 3,
      pricePerKgSnapshot: 45,
      deliveryFeeSnapshot: 39,
      totalAmount: 174,
      addressLine: '8, Palam Nagar, West Street',
      lat: 10.595,
      lng: 76.289,
      distanceKm: 7.8,
      deliverySlot: '2–5 pm',
      status: 'placed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1048',
      buyerId: 'u5',
      buyerName: 'Anil George',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 6,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 16,
      totalAmount: 376,
      addressLine: '3, Church Road, opposite school',
      lat: 10.549,
      lng: 76.233,
      distanceKm: 3.1,
      deliverySlot: '9–12 am',
      status: 'delivered',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
    PineappleOrder(
      id: 'order_1047',
      buyerId: 'u6',
      buyerName: 'Meera Pillai',
      batchId: 'batch_a',
      grade: 'A',
      quantityKg: 4,
      pricePerKgSnapshot: 60,
      deliveryFeeSnapshot: 28,
      totalAmount: 268,
      addressLine: '21, Gandhi Nagar, 2nd Cross',
      lat: 10.571,
      lng: 76.258,
      distanceKm: 5.5,
      deliverySlot: '2–5 pm',
      status: 'confirmed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
    ),
  ];
}
