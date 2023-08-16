import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';

import 'location_callback_handler.dart';

class Footer extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const Footer({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _Footer createState() => _Footer();
}

class _Footer extends State<Footer> {
  //static const String _isolateName = "LocatorIsolate";
  ReceivePort port = ReceivePort();

  @override
  void initState() {
    super.initState();

    // IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    // port.listen((dynamic data) {
    //   //debugPrint(data.toString());
    // });
    initPlatformState();
    _startLocator();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  void _startLocator() {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city),
          label: 'スポット',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      ],
      iconSize: 24,
      selectedFontSize: 15,
      unselectedFontSize: 10,
    );
  }
}
