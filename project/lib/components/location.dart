import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  LocationData? currentLocation;

  void updateLocation(LocationData newLocation) {
    currentLocation = newLocation;
    notifyListeners();
  }
}

Map<String, DateTime> arrived = {};

final List<Map<String, dynamic>> locations = [
  {'label': '生田キャンパス', 'lat': 35.612850, 'lng': 139.549127, 'radius': 700.0},
  {'label': '新百合ヶ丘駅', 'lat': 35.60344, 'lng': 139.507754, 'radius': 100.0},
  {'label': '新宿駅', 'lat': 35.689607, 'lng': 139.700571, 'radius': 150.0},
];

Set<Circle> createCircle() {
  Set<Circle> circle = {};
  int count = 0;
  for (Map location in locations) {
    count += 1;
    circle.add(Circle(
        circleId: CircleId(count.toString()),
        center: LatLng(location['lat'], location['lng']),
        radius: location['radius'],
        strokeColor: Colors.pink.withOpacity(0.6),
        fillColor: Colors.pink.withOpacity(0.2),
        strokeWidth: 2));
  }
  return circle;
}
