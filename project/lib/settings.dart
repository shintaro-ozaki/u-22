import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/database_helper.dart';
import 'footer.dart';
import 'main.dart';
import 'map.dart';
import './components/amount_provider.dart';
import './components/frequency_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
  int _amount = 0;
  String _newFrequency = '指定なし';
  final dbInfo = DatabaseInformation.instance;
  bool _isAmountValid = true;

  @override
  void initState() {
    super.initState();
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    final frequencyProvider =
        Provider.of<FrequencyProvider>(context, listen: false);
    _amount = amountProvider.amount;
    switch (frequencyProvider.selectedFrequency) {
      case NotificationFrequency.unspecified:
        _newFrequency = '指定なし';
      case NotificationFrequency.oncePerDay:
        _newFrequency = '1日に1回';
      case NotificationFrequency.oncePerthreeTimesDays:
        _newFrequency = '3日に1回';
      case NotificationFrequency.oncePerWeek:
        _newFrequency = '1週間に1回';
    }
  }

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
    }
  }

  void _updateAmount(int value) {
    setState(() {
      _amount = value;
    });
  }

  void _apply() async {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    final frequencyProvider =
        Provider.of<FrequencyProvider>(context, listen: false);

    Map<String, dynamic> infoData = {
      'timestamp': DateTime.now().toString(),
      'frequency': _newFrequency,
      'setamount': _amount,
    };
    await DatabaseInformation.instance.insertInfo(infoData);
    setState(() {});

    NotificationFrequency selectedFrequencyValue =
        convertToNotificationFrequency(_newFrequency);

    // 新しい頻度を設定
    frequencyProvider.setSelectedFrequency(selectedFrequencyValue);

    // 新しい金額を設定
    amountProvider.setAmount(_amount);
  }

  double getFontSize(double coefficient) {
    return MediaQuery.of(context).size.width * coefficient;
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);

    final List<String> frequencyOptions = [
      '指定なし',
      '1日に1回',
      '3日に1回',
      '1週間に1回',
    ];

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            '設定画面',
            style: TextStyle(fontSize: getFontSize(0.06)),
          ),
          backgroundColor: Colors.orangeAccent),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // フォーカスを外す
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  '設定金額',
                  style: TextStyle(
                      fontSize: getFontSize(0.06), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixText: '¥',
                    errorText: _isAmountValid ? null : '1円から100円までの整数を入力してください',
                  ),
                  onChanged: (value) {
                    final amount = int.tryParse(value);
                    setState(() {
                      if (value.isEmpty) {
                        _isAmountValid = true;
                        _updateAmount(amountProvider.amount);
                      } else if (amount != null &&
                          amount >= 1 &&
                          amount <= 100) {
                        _updateAmount(amount);
                        _isAmountValid = true;
                      } else {
                        _isAmountValid = false;
                      }
                    });
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Text(
                  '決済頻度',
                  style: TextStyle(
                      fontSize: getFontSize(0.06), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _newFrequency,
                      onChanged: (newValue) {
                        // ignore: unused_local_variable
                        NotificationFrequency selectedFrequencyValue =
                            convertToNotificationFrequency(newValue!);
                        setState(() {
                          _newFrequency = newValue;
                        });
                      },
                      items: frequencyOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                    ElevatedButton(
                      // 金額が正しくないときはボタンが無効
                      onPressed: _isAmountValid ? _apply : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text(
                        '設定を反映する',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Text(
                  '現在の設定',
                  style: TextStyle(
                      fontSize: getFontSize(0.06), fontWeight: FontWeight.bold),
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
                      String currentFrequency = '指定してください';

                      if (lastInfo != null) {
                        currentAmount = lastInfo['setamount'] as int;
                        currentFrequency =
                            lastInfo['frequency'] as String? ?? '反映されてません';
                      }

                      return Table(
                        columnWidths: {
                          0: FixedColumnWidth(
                              MediaQuery.of(context).size.width * 0.3),
                          1: FixedColumnWidth(
                              MediaQuery.of(context).size.width * 0.3),
                        },
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                  child: Container(
                                alignment: Alignment.centerRight, // 右詰にする
                                child: Text(
                                  '設定金額',
                                  style: TextStyle(
                                      fontSize: getFontSize(0.05),
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                              TableCell(
                                  child: Container(
                                alignment: Alignment.centerRight, // 右詰にする
                                child: Text(
                                  '$currentAmount円',
                                  style: TextStyle(
                                      fontSize: getFontSize(0.05),
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                  child: Container(
                                alignment: Alignment.centerRight, // 右詰にする
                                child: Text(
                                  '決済頻度',
                                  style: TextStyle(
                                      fontSize: getFontSize(0.05),
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                              TableCell(
                                  child: Container(
                                alignment: Alignment.centerRight, // 右詰にする
                                child: Text(
                                  currentFrequency,
                                  style: TextStyle(
                                      fontSize: getFontSize(0.05),
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          )),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
