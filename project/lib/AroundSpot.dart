import 'dart:async';
import 'package:flutter/material.dart';
import 'footer.dart';
import 'main.dart';
import 'settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AroundSpotPage extends StatefulWidget {
  const AroundSpotPage({super.key});

  @override
  _AroundSpotPageState createState() => _AroundSpotPageState();
}

class _AroundSpotPageState extends State<AroundSpotPage> {
  //  Google Map API
  final Location _locationService = Location();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 現在位置
  LocationData? _yourLocation;

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

  int _switch = 0;

  // Footer
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    // 現在位置の取得
    _locationService.enableBackgroundMode(enable: true);
    _getLocation();
    _initializePlatformSpecifics();

    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 30),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) {
        _switch = 0;
        setState(() {});
      },
    );

    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
      setState(() {
        _yourLocation = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    // 監視を終了
    _locationChangedListen?.cancel();
  }

  //Footer
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('近くのスポット'),
      ),
      body: _makeGoogleMap(),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _makeGoogleMap() {
    if (_yourLocation == null) {
      // 現在位置が取れるまではローディング中
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      debugPrint(_yourLocation.toString());
      if (_yourLocation.toString() ==
              'LocationData<lat: 37.33233141, long: -122.0312186>' &&
          _switch == 0) {
        _switch = 1;
        _showNotification();
      }
      // Google Map ウィジェットを返す
      return GoogleMap(
        // 初期表示される位置情報を現在位置から設定
        initialCameraPosition: CameraPosition(
          target: LatLng(
              _yourLocation?.latitude ?? 0.0, _yourLocation?.longitude ?? 0.0),
          zoom: 18.0,
        ),
        onMapCreated: (controller) {},
        // 現在位置にアイコン（青い円形のやつ）を置く
        myLocationEnabled: true,
      );
    }
  }

  void _getLocation() async {
    _yourLocation = await _locationService.getLocation();
  }

  void _initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) {
      debugPrint('payload:${res.payload}');
    });
  }

  Future<void> _showNotification() async {
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      '募金しますか？', // Notification Title
      null, // Notification Body, set as null to remove the body
      platformChannelSpecifics,
      payload: 'New Payload', // Notification Payload
    );
  }
}
