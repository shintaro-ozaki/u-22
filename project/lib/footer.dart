import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:project/components/frequency_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './components/location.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './components/amount_provider.dart';
import './db/database_helper.dart';

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

  final Location _locationService = Location();

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

  final NetworkInfo info = NetworkInfo();

  int beforeHour = 0;

  @override
  void initState() {
    super.initState();

    // 初期化
    _initializePlatformSpecifics();
    _locationService.enableBackgroundMode(enable: true);

    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      debugPrint(result.toString());
      locationProvider.updateLocation(result);
      DateTime nowTime = DateTime.now();
      debugPrint((beforeHour - nowTime.hour).toString());
      debugPrint(arrived.toString());
      if (beforeHour - nowTime.hour == 23) {
        initArrived();
      }
      beforeHour = nowTime.hour;
      if (await checkFrequency(nowTime)) {
        if (await checkSpot()) {
          _showNotification();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 監視を終了
    _locationChangedListen?.cancel();
  }

  Future<bool> checkFrequency(DateTime nowTime) async {
    final frequencyProvider =
        Provider.of<FrequencyProvider>(context, listen: false);
    String lastPayment =
        await DatabaseHelper.instance.getLastPaymentTimestamp();
    //debugPrint(lastPayment);
    if (lastPayment != '') {
      DateTime lastPaymentTime = DateTime.parse(lastPayment);
      DateTime lastPaymentTimeZero = DateTime(
          lastPaymentTime.year, lastPaymentTime.month, lastPaymentTime.day);
      switch (frequencyProvider.selectedFrequency) {
        case NotificationFrequency.unspecified:
          return true;
        case NotificationFrequency.oncePerDay:
          DateTime resetTime = lastPaymentTimeZero.add(const Duration(days: 1));
          if (resetTime.isAfter(nowTime)) {
            return false;
          }
        case NotificationFrequency.oncePerThreeDays:
          DateTime resetTime = lastPaymentTimeZero.add(const Duration(days: 3));
          if (resetTime.isAfter(nowTime)) {
            return false;
          }
        case NotificationFrequency.oncePerWeek:
          DateTime resetTime = lastPaymentTimeZero.add(const Duration(days: 7));
          if (resetTime.isAfter(nowTime)) {
            return false;
          }
      }
    }
    return true;
  }

  Future<bool> checkSpot() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    double rangeLat = 0.0, diffLat = 0.0, rangeLng = 0.0, diffLng = 0.0;
    // 位置情報判定
    for (Map location in locations) {
      if (arrived.contains(location)) {
        continue;
      }
      rangeLat = location['radius'] * 0.000009;
      rangeLng = location['radius'] * 0.000011;
      diffLat = location['lat'] - locationProvider.currentLocation?.latitude;
      diffLng = location['lng'] - locationProvider.currentLocation?.longitude;
      if ((-rangeLat < diffLat && diffLat < rangeLat) &&
          (-rangeLng < diffLng && diffLng < rangeLng)) {
        arrived.add(location);
        return true;
      }
    }
    // // wifi判定
    // String? wifiName = await info.getWifiName();
    // debugPrint(wifiName);
    // if (wifiName == 'foo') {
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
        Uri.parse('http://192.168.10.101:5001/donate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "merchantPaymentId": merchantPaymentId,
          "codeType": "ORDER_QR",
          "redirectUrl": "main.dart",
          "redirectType": "APP_DEEP_LINK",
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
