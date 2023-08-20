import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './components/location.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './components/amount_provider.dart';
import './db/database_helper.dart';

late LocationData? currentLocation;

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final info = NetworkInfo();

  final Location _locationService = Location();

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

  String wifiName = '';

  bool notify = true;

  @override
  void initState() {
    super.initState();

    // 初期化
    _initializePlatformSpecifics();
    _locationService.enableBackgroundMode(enable: true);

    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
      setState(() {
        // Future<String?> wifiName = info.getWifiName();
        // debugPrint(wifiName.toString());
        currentLocation = result;
        if (currentLocation != null) {
          // debugPrint(currentLocation.toString());
          if (notify && check()) {
            _showNotification();
            notify = false;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 監視を終了
    _locationChangedListen?.cancel();
  }

  bool check() {
    double rangeLat = 0.0, diffLat = 0.0, rangeLng = 0.0, diffLng = 0.0;
    // 位置情報判定
    for (Map location in locations) {
      rangeLat = location['radius'] * 0.000009;
      rangeLng = location['radius'] * 0.000011;
      diffLat = location['lat'] - currentLocation?.latitude;
      diffLng = location['lng'] - currentLocation?.longitude;
      if ((-rangeLat < diffLat && diffLat < rangeLat) &&
          (-rangeLng < diffLng && diffLng < rangeLng)) {
        return true;
      }
    }
    // wifi判定
    // if (wifiName == '') {
    //   return true;
    // }
    return false;
  }

  String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(characters[random.nextInt(characters.length)]);
    }

    return buffer.toString();
  }

  Future<void> _onDonateButtonPressed() async {
    final merchantPaymentId = generateRandomString(30);
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    try {
      final response = await http.post(
        // need to change address where you are located in.
        Uri.parse('http://127.0.0.1:5001/donate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "merchantPaymentId": merchantPaymentId,
          "codeType": "ORDER_QR",
          "redirectUrl": "main.dart",
          "redirectType": "APP_DEEP_LINK",
          // "redirectUrl": "",
          // "redirectType": "WEB_LINK",
          "orderDescription": "募金グループへ",
          "orderItems": [
            {
              "name": "募金",
              "category": "pasteries",
              "quantity": 1,
              "productId": "67678",
              "unitPrice": {"amount": amountProvider.amount, "currency": "JPY"},
            }
          ],
          "amount": {"amount": amountProvider.amount, "currency": "JPY"},
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final redirectUrl = responseBody['redirectUrl'];
        // ignore: deprecated_member_use
        await launch(redirectUrl);
        await DatabaseHelper.instance.insertPayment({
          'timestamp': DateTime.now().toIso8601String(),
          'amount': amountProvider.amount,
        });
        setState(() {});
      } else {
        // ignore: avoid_print
        print('寄付が失敗しました');
      }
    } catch (e) {
      // ignore: avoid_print
      print('エラー: $e');
    }
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
      _onDonateButtonPressed();
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AmountProvider(),
      child: BottomNavigationBar(
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
      ),
    );
  }
}
