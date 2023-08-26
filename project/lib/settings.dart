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
  bool _isAmountValid = false;

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
    Map<String, dynamic> infoData = {
      'timestamp': DateTime.now().toString(),
      'frequency': _newFrequency,
      'setamount': _amount,
    };
    await DatabaseInformation.instance.insertInfo(infoData);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context);
    final frequencyProvider = Provider.of<FrequencyProvider>(context);

    final List<String> frequencyOptions = [
      '指定なし',
      '1日に1回',
      '3日に1回',
      '1週間に1回',
    ];

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '設定画面',
            style: TextStyle(color: Colors.black),
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
                const Text(
                  '通知設定',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Text(
                      '通知の頻度を選択してください:',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: _newFrequency,
                      onChanged: (newValue) {
                        NotificationFrequency selectedFrequencyValue =
                            convertToNotificationFrequency(newValue!);
                        setState(() {
                          _newFrequency = newValue;
                          frequencyProvider
                              .setSelectedFrequency(selectedFrequencyValue);
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
                    const SizedBox(height: 20),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '募金金額を設定する',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixText: '¥',
                    suffixText: '円',
                    errorText: _isAmountValid ? null : '1円から100円までの整数を入力してください',
                  ),
                  onChanged: (value) {
                    final amount = int.tryParse(value);
                    setState(() {
                      if (value.isEmpty) {
                        _isAmountValid = false;
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
                const SizedBox(height: 20),
                ElevatedButton(
                  // 金額が正しくないときはボタンが無効
                  onPressed: _isAmountValid ? _apply : null,
                  child: const Text('設定を反映する'),
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
