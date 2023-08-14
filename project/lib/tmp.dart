import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'map.dart';

void main() => runApp(const FirstView());

class Const {
  static const routeFirstView = '/first';
}

class FirstView extends StatelessWidget {
  const FirstView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      routes: <String, WidgetBuilder>{
        Const.routeFirstView: (BuildContext context) => const MapPage(),
      },
      home: _FirstView(),
    );
  }
}

class _FirstView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    permission();
    debugPrint('test');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, Const.routeFirstView),
          child: const Text('Launch the map'),
        ),
      ),
    );
  }

  Future<void> permission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    Location locationService = Location();

    serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}
