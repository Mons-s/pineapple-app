/// A placed order. Price, address and distance are stored as snapshots
/// (copies) so editing a batch's price or a saved address later never
/// changes the record of what the buyer actually paid.
class PineappleOrder {
  final String id;
  final String buyerId;
  final String buyerName;
  final String batchId;
  final String grade;
  final double quantityKg;
  final double pricePerKgSnapshot;
  final double deliveryFeeSnapshot;
  final double totalAmount;
  final String addressLine;
  final double lat;
  final double lng;
  final double distanceKm;
  final String deliverySlot;
  final String status; // placed | confirmed | out_for_delivery | delivered | cancelled
  final String paymentStatus; // pending | paid | failed
  final DateTime createdAt;

  const PineappleOrder({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.batchId,
    required this.grade,
    required this.quantityKg,
    required this.pricePerKgSnapshot,
    required this.deliveryFeeSnapshot,
    required this.totalAmount,
    required this.addressLine,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.deliverySlot,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
  });

  PineappleOrder copyWith({String? status, String? paymentStatus}) {
    return PineappleOrder(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      batchId: batchId,
      grade: grade,
      quantityKg: quantityKg,
      pricePerKgSnapshot: pricePerKgSnapshot,
      deliveryFeeSnapshot: deliveryFeeSnapshot,
      totalAmount: totalAmount,
      addressLine: addressLine,
      lat: lat,
      lng: lng,
      distanceKm: distanceKm,
      deliverySlot: deliverySlot,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
    );
  }

  factory PineappleOrder.fromMap(String id, Map<String, dynamic> map) {
    return PineappleOrder(
      id: id,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      batchId: map['batchId'] ?? '',
      grade: map['grade'] ?? 'A',
      quantityKg: (map['quantityKg'] ?? 0).toDouble(),
      pricePerKgSnapshot: (map['pricePerKgSnapshot'] ?? 0).toDouble(),
      deliveryFeeSnapshot: (map['deliveryFeeSnapshot'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      addressLine: map['addressLine'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      deliverySlot: map['deliverySlot'] ?? '',
      status: map['status'] ?? 'placed',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAtMs'] ?? 0),
    );
  }
}
