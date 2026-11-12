/// A saved buyer address, including the map pin used for the
/// 10 km delivery-radius check.
class DeliveryAddress {
  final String id;
  final String label;
  final String addressLine;
  final double lat;
  final double lng;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromMap(String id, Map<String, dynamic> map) {
    return DeliveryAddress(
      id: id,
      label: map['label'] ?? '',
      addressLine: map['addressLine'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'addressLine': addressLine,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }
}
