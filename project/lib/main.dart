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
  String lastPaymentTimestamp = '';

  double getFontSize(double coefficient) {
    return MediaQuery.of(context).size.width * coefficient;
  }

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

    Future<String> fetchLastPaymentTimestamp() async {
      String timestamp =
          await DatabaseHelper.instance.getLastPaymentTimestamp();
      if (timestamp == '') {
        return '無し';
      } else {
        DateTime dateTimeTimestamp =
            DateTime.parse(timestamp); // StringをDateTimeに変換
        final formatter = DateFormat('MM月dd日');
        String formattedDate = formatter.format(dateTimeTimestamp);
        return formattedDate;
      }
    }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.width * 0.55,
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
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        children: [
                          Text(
                            '累計額',
                            style: TextStyle(
                              fontSize: getFontSize(0.05),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                          Icon(
                            Icons.attach_money,
                            size: getFontSize(0.05),
                            color: Colors.blue,
                          ),
                          Row(
                            children: [
                              Text(
                                cumulativeAmount.toString(),
                                style: TextStyle(
                                  fontSize: getFontSize(0.08),
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 76, 79, 255),
                                ),
                              ),
                              Text(
                                ' 円',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '今週の累計額',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatWeekDate(DateTime.now()).toString(),
                                style: TextStyle(
                                  fontSize: getFontSize(0.03),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.245),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: getFontSize(0.05),
                                color: Colors.blue, // お好きな色を選んでください
                              ),
                              Text(
                                weeklyTotal.toString(),
                                style: TextStyle(
                                  fontSize: getFontSize(0.08),
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 76, 79, 255),
                                ),
                              ),
                              Text(
                                ' 円',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                      currentFrequency =
                          lastInfo['frequency'] as String? ?? "1";
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04),
                          child: Row(
                            children: [
                              Text(
                                '設定金額',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.385),
                              Icon(
                                Icons.attach_money,
                                size: getFontSize(0.05),
                                color: Colors.blue, // お好きな色を選んでください
                              ),
                              Text(
                                '$currentAmount',
                                style: TextStyle(
                                  fontSize: getFontSize(0.08),
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                              Text(
                                ' 円',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04),
                          child: Row(
                            children: [
                              Text(
                                '決済頻度',
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.365),
                              Text(
                                currentFrequency,
                                style: TextStyle(
                                  fontSize: getFontSize(0.05),
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        FutureBuilder<String>(
                          future: fetchLastPaymentTimestamp(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final lastPaymentText =
                                  snapshot.data ?? 'まだ募金をしていません';
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '最後に募金した日',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42),
                                    Text(
                                      lastPaymentText,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '・ 届いた通知を押すと、設定した金額を募金することができます',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.025),
                              ),
                              Text(
                                '・ 設定した金額や頻度は設定画面より変更することができます',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.025),
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
      ),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
