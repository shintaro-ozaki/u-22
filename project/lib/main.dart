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
              return const Scaffold(backgroundColor: Colors.white);
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
    // final currentDate = DateTime.now();
    // final weekDateRange = formatWeekDate(currentDate);

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
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10), // 左右のパディングを追加
        // mainAxisAlignment: MainAxisAlignment.center,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 192, 192, 192)
                        .withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(150),
                child: Image.asset(
                  'assets/images/banner.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 60),
            FutureBuilder<int>(
              future: fetchCumulativeAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final cumulativeAmount = snapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // 左右のパディングを追加
                    // mainAxisAlignment: MainAxisAlignment.center,
                    child: Row(
                      children: [
                        const Text(
                          '累計額',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 190), // テキスト間のスペーシング
                        const Icon(
                          Icons.attach_money,
                          size: 24,
                          color: Colors.blue, // お好きな色を選んでください
                        ),
                        Row(
                          children: [
                            Text(
                              cumulativeAmount.toString(),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              ' 円',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: getWeeklyDonationTotal(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final weeklyTotal = snapshot.data ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16), // 左右のパディングを追加
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '今週の累計額',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatWeekDate(DateTime.now()).toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 100),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 24,
                              color: Colors.blue, // お好きな色を選んでください
                            ),
                            Text(
                              weeklyTotal.toString(),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              ' 円',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
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
                  String currentFrequency = '設定画面より指定してください';
                  if (lastInfo != null) {
                    currentAmount = lastInfo['setamount'] as int;
                    currentFrequency = lastInfo['frequency'] as String? ?? "1";
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              '設定金額',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 173),
                            const Icon(
                              Icons.attach_money,
                              size: 24,
                              color: Colors.blue, // お好きな色を選んでください
                            ),
                            Text(
                              '$currentAmount',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              ' 円',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              '決済頻度',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 150),
                            Text(
                              currentFrequency,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // テキストを左寄せに配置
                          children: [
                            Text(
                              '・ 届いた通知を押すと、設定した金額を募金することができます',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              '・ 金額や頻度は設定画面より変更することができます',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              },
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
