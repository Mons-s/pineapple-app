import 'dart:math';

/// Mirrors the server-side check the placeOrder Cloud Function runs.
/// Used in the app only to give the buyer instant feedback on the map
/// screen — the Cloud Function is what actually enforces the rule.
class DeliveryRules {
  static const double vendorLat = 10.5276; // TODO: replace with your farm's real coordinates
  static const double vendorLng = 76.2144;
  static const double radiusKm = 10;
  static const double ratePerKm = 5; // delivery fee rule: flat rate per km
  static const double minOrderKg = 3;

  /// Straight-line ("as the crow flies") distance in km.
  static double distanceKm(double lat, double lng) {
    const r = 6371.0;
    final dLat = _toRad(lat - vendorLat);
    final dLng = _toRad(lng - vendorLng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(vendorLat)) * cos(_toRad(lat)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static bool isWithinRadius(double lat, double lng) => distanceKm(lat, lng) <= radiusKm;

  static double deliveryFee(double distance) => (ratePerKm * distance).roundToDouble();

  static double _toRad(double deg) => deg * pi / 180;
}
