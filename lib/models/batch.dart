/// One harvest batch of pineapples — the real "product" in this app.
/// Price, stock and the quality certificate are all tracked per batch
/// because they change with every harvest.
class Batch {
  final String id;
  final String grade; // "A" or "B"
  final double pricePerKg;
  final double stockKg;
  final DateTime harvestDate;
  final String certificateUrl;
  final String certificateIssuedBy;
  final DateTime certificateDate;
  final double brixSweetness;
  final String status; // active | sold_out | expired
  final double ratingAvg;
  final int ratingCount;

  const Batch({
    required this.id,
    required this.grade,
    required this.pricePerKg,
    required this.stockKg,
    required this.harvestDate,
    required this.certificateUrl,
    required this.certificateIssuedBy,
    required this.certificateDate,
    required this.brixSweetness,
    required this.status,
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });

  bool get isAvailable => status == 'active' && stockKg > 0;

  factory Batch.fromMap(String id, Map<String, dynamic> map) {
    return Batch(
      id: id,
      grade: map['grade'] ?? 'A',
      pricePerKg: (map['pricePerKg'] ?? 0).toDouble(),
      stockKg: (map['stockKg'] ?? 0).toDouble(),
      harvestDate: DateTime.fromMillisecondsSinceEpoch(map['harvestDateMs'] ?? 0),
      certificateUrl: map['certificateUrl'] ?? '',
      certificateIssuedBy: map['certificateIssuedBy'] ?? '',
      certificateDate: DateTime.fromMillisecondsSinceEpoch(map['certificateDateMs'] ?? 0),
      brixSweetness: (map['brixSweetness'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
      ratingAvg: (map['ratingAvg'] ?? 0).toDouble(),
      ratingCount: (map['ratingCount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'pricePerKg': pricePerKg,
      'stockKg': stockKg,
      'harvestDateMs': harvestDate.millisecondsSinceEpoch,
      'certificateUrl': certificateUrl,
      'certificateIssuedBy': certificateIssuedBy,
      'certificateDateMs': certificateDate.millisecondsSinceEpoch,
      'brixSweetness': brixSweetness,
      'status': status,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
    };
  }
}
