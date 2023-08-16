import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AmountProvider.dart';
import 'AroundSpot.dart';
import 'database_helper.dart';
import 'footer.dart';
import 'settings.dart';
import 'FrequencyProvider.dart';
import 'NotifierProvider.dart';
import 'package:location/location.dart';
import 'map.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class Const {
  static const routeFirstView = '/first';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    permission();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AmountProvider()),
        ChangeNotifierProvider(create: (context) => FrequencyProvider()),
        ChangeNotifierProvider(
            create: (context) => NotificationSettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'ホーム'),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final dbHelper = DatabaseHelper.instance;

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

  Future<void> _onDonateButtonPressed() async {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    final merchantPaymentId = generateRandomString(30);
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
          "redirectUrl": "",
          "redirectType": "WEB_LINK",
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
        final now = DateTime.now();
        final timestamp = now.toIso8601String();
        await DatabaseHelper.instance.insert(amountProvider.amount, timestamp);
      } else {
        print('寄付が失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context);
    final frequencyProvider = Provider.of<FrequencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _onDonateButtonPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('1円以上で募金できます'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<double>(
              future: getTotalAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('エラー: ${snapshot.error}');
                } else {
                  final totalAmount = snapshot.data ?? 0;
                  return Text(
                    '総金額: $totalAmount 円',
                    style: const TextStyle(fontSize: 18),
                  );
                }
              },
            ),
            Text(
              '現在の金額: ${amountProvider.amount} 円',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              '現在の頻度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              () {
                switch (frequencyProvider.selectedFrequency) {
                  case NotificationFrequency.unspecified:
                    return '指定なし';
                  case NotificationFrequency.oncePerDay:
                    return '1日に1回';
                  case NotificationFrequency.threeTimesPerDay:
                    return '1日に3回';
                  case NotificationFrequency.oncePerWeek:
                    return '1週間に1回';
                  default:
                    return 'その他の設定';
                }
              }(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<double> getTotalAmount() async {
    final rows = await DatabaseHelper.instance.queryAllRows();
    int totalAmount = 0;
    for (var row in rows) {
      totalAmount += (row[DatabaseHelper.columnAmount] as int);
    }
    print(totalAmount);
    return totalAmount.toDouble();
  }
}
