import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './components/location.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'footer.dart';
import 'map.dart';
import 'settings.dart';
import './components/amount_provider.dart';
import './components/frequency_provider.dart';
import 'dart:async';
import './db/database_helper.dart';
import 'lock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AmountProvider()),
        ChangeNotifierProvider(create: (context) => FrequencyProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: checkPermission(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return const MyHomePage(title: 'ホーム');
            } else if (snapshot.data == false) {
              return const LockPage(title: '制限モード');
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final dbInfo = DatabaseInformation.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
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
      final currentDate = DateTime.now();
      final monday =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: fetchCumulativeAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
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
            FutureBuilder<Map<String, dynamic>?>(
              future: dbInfo.getLastInformation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final lastInfo = snapshot.data;

                  int currentAmount = amountProvider.amount;
                  String currentFrequency = 'Not specified';

                  if (lastInfo != null) {
                    currentAmount = lastInfo['setamount'] as int;
                    currentFrequency = lastInfo['frequency'] as String;
                  }

                  return Column(
                    children: [
                      Text(
                        '現在の金額: $currentAmount 円',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '現在の頻度: $currentFrequency',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }
              },
            ),
            Image.asset(
              'assets/images/s2.png',
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
}
