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
  {'label': '生田駅', 'lat': 35.615014, 'lng': 139.542235, 'radius': 100.0},
  {'label': '新百合ヶ丘駅', 'lat': 35.60344, 'lng': 139.507754, 'radius': 100.0},
  {'label': 'tmp', 'lat': 35.61243, 'lng': 139.541453, 'radius': 50.0},
  // 東京
  {'label': '新宿駅', 'lat': 35.689607, 'lng': 139.700571, 'radius': 200.0},
  {'label': '渋谷駅', 'lat': 35.658034, 'lng': 139.701636, 'radius': 200.0},
  {'label': '池袋駅', 'lat': 35.729503, 'lng': 139.7109, 'radius': 175.0},
  {'label': '北千住駅', 'lat': 35.749676, 'lng': 139.805343, 'radius': 150.0},
  {'label': '東京駅', 'lat': 35.681236, 'lng': 139.767125, 'radius': 200.0},
  {'label': '東京スカイツリー', 'lat': 35.710063, 'lng': 139.8107, 'radius': 75.0},
  {'label': '東京タワー', 'lat': 35.658581, 'lng': 139.745433, 'radius': 75.0},
  {'label': '東京ビッグサイト', 'lat': 35.632141, 'lng': 139.797464, 'radius': 250.0},
  {'label': '国立競技場', 'lat': 35.677824, 'lng': 139.714541, 'radius': 200.0},
  {'label': '代々木公園', 'lat': 35.671587, 'lng': 139.696703, 'radius': 300.0},

  // 全国
  {'label': '新千歳空港', 'lat': 42.77913, 'lng': 141.686637, 'radius': 1000.0},
  {'label': '仙台駅', 'lat': 38.260132, 'lng': 140.882438, 'radius': 200.0},
  {'label': '新横浜駅', 'lat': 35.506808, 'lng': 139.617577, 'radius': 200.0},
  {'label': '名古屋駅', 'lat': 35.170915, 'lng': 136.881537, 'radius': 250.0},
  {'label': '新大阪駅', 'lat': 34.733466, 'lng': 135.500255, 'radius': 175.0},
  {'label': '広島駅', 'lat': 34.397667, 'lng': 132.475379, 'radius': 200.0},
  {'label': '高松駅', 'lat': 34.35068, 'lng': 134.046928, 'radius': 100.0},
  {'label': '博多駅', 'lat': 33.589728, 'lng': 130.420727, 'radius': 200.0},
  {'label': '那覇空港', 'lat': 26.20013, 'lng': 127.646645, 'radius': 800.0},
  {'label': '生田キャンパス', 'lat': 35.612850, 'lng': 139.549127, 'radius': 200.0},
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
