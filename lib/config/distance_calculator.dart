import 'dart:math';

double calculateDistance(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const double earthRadius = 6371;

  double dLat = _degToRad(endLat - startLat);
  double dLon = _degToRad(endLng - startLng);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(startLat)) *
          cos(_degToRad(endLat)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}