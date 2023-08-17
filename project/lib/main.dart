import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'AmountProvider.dart';
import 'AroundSpot.dart';
import 'footer.dart';
import 'settings.dart';
import 'FrequencyProvider.dart';
import 'NotifierProvider.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';

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
        await launch(redirectUrl);
        await DatabaseHelper.instance.insertPayment({
          'timestamp': DateTime.now().toIso8601String(),
          'amount': amountProvider.amount,
        });
        setState(() {});
      } else {
        print('寄付が失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
    }
  }

  String formatWeekDate(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final formatter = DateFormat('MM月dd日');
    final mondayFormatted = formatter.format(monday);
    final sundayFormatted = formatter.format(sunday);

    return '$mondayFormatted から $sundayFormatted';
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context);
    final frequencyProvider = Provider.of<FrequencyProvider>(context);
    final currentDate = DateTime.now();
    final weekDateRange = formatWeekDate(currentDate);

    Future<int> fetchCumulativeAmount() async {
      final allPayments = await DatabaseHelper.instance.getAllPayments();
      return allPayments.fold<int>(
        0,
        (previousValue, payment) => previousValue + (payment['amount'] as int),
      );
    }

    Future<int> getWeeklyDonationTotal(context) async {
      final db = await DatabaseHelper.instance.database;

      // Calculate the start and end dates for the current week (Monday to Sunday)
      final currentDate = DateTime.now();
      final monday =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      // Query the database for donations within the week's date range
      final total = Sqflite.firstIntValue(await db.rawQuery('''
    SELECT SUM(amount) FROM payments
    WHERE timestamp BETWEEN ? AND ?
  ''', [monday.toIso8601String(), sunday.toIso8601String()]));

      return total ?? 0;
    }

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
            FutureBuilder<int>(
              future: fetchCumulativeAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final cumulativeAmount = snapshot.data ?? 0;
                  return Text(
                    '累計金額: $cumulativeAmount 円',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            Text(
              '今週の日付範囲: $weekDateRange',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<int>(
              future: getWeeklyDonationTotal(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final weeklyTotal = snapshot.data ?? 0;
                  return Text(
                    '週間の募金累計額: $weeklyTotal 円',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
            Image.asset(
              'assets/images/s2.png',
            ),
            // SizedBox(
            //   width: 300, // Set an appropriate width for your chart
            //   height: 200, // Set an appropriate height for your chart
            //   child: LineChart(
            //     LineChartData(
            //       titlesData: const FlTitlesData(
            //         show: true,
            //         //右タイトル
            //         rightTitles:
            //             AxisTitles(sideTitles: SideTitles(showTitles: false)),
            //         //上タイトル
            //         topTitles: AxisTitles(
            //           sideTitles: SideTitles(showTitles: false),
            //         ),
            //         //下タイトル
            //         bottomTitles: AxisTitles(
            //           // axisNameWidget: Text('ブログ運営年月',style: _labelStyle,),
            //           // axisNameSize: 40,
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //           ),
            //         ),
            //         // 左タイトル
            //         leftTitles: AxisTitles(
            //           // axisNameWidget: Text('記事数',style: _labelStyle,),
            //           // axisNameSize: 25,
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //           ),
            //         ),
            //       ),
            //       gridData: const FlGridData(show: false),
            //       borderData: FlBorderData(show: false),
            //       lineBarsData: [
            //         LineChartBarData(
            //           spots: [
            //             // You need to populate this list with data points
            //             const FlSpot(
            //                 0, 100), // Example data point (time, amount)
            //             const FlSpot(1, 150),
            //             // ... Add more data points
            //           ],
            //           isCurved: true,
            //           color: const Color.fromARGB(255, 63, 169, 255),
            //           dotData: const FlDotData(show: false),
            //           belowBarData: BarAreaData(show: false),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
