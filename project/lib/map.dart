import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'footer.dart';
import 'main.dart';
import 'settings.dart';
import './components/location.dart';

class AroundSpotPage extends StatefulWidget {
  const AroundSpotPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AroundSpotPageState createState() => _AroundSpotPageState();
}

class _AroundSpotPageState extends State<AroundSpotPage> {
  // ignore: unused_field
  GoogleMapController? _googleMapController;

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'ホーム')),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AroundSpotPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Google Map page",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.lightGreen),
      body: _makeGoogleMap(),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _makeGoogleMap() {
    if (currentLocation == null) {
      // 現在位置が取れるまではローディング中
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // Google Map ウィジェットを返す
      return GoogleMap(
        // 初期表示される位置情報を現在位置から設定
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation?.latitude ?? 0.0,
              currentLocation?.longitude ?? 0.0),
          zoom: 16.0,
        ),
        circles: createCircle(),
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
        // 現在位置にアイコン（青い円形のやつ）を置く
        myLocationEnabled: true,
      );
    }
  }
}