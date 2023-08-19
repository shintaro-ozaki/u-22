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
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
  int _amount = 0;
  String _selectedFrequency = '指定なし';
  final dbInfo = DatabaseInformation.instance;

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

  void _updateAmount(int value) {
    setState(() {
      _amount = value;
    });
  }

  void _apply() async {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    final frequencyProvider =
        Provider.of<FrequencyProvider>(context, listen: false);

    // Insert data into the database
    Map<String, dynamic> infoData = {
      'timestamp': DateTime.now().toString(),
      'frequency': _selectedFrequency,
      'setamount': _amount,
    };
    int insertedId = await DatabaseInformation.instance.insertInfo(infoData);
    debugPrint('Inserted data with ID: $insertedId');

    amountProvider.setAmount(_amount);

    NotificationFrequency selectedFrequencyValue;
    switch (_selectedFrequency) {
      case '指定なし':
        selectedFrequencyValue = NotificationFrequency.unspecified;
        break;
      case '1日に1回':
        selectedFrequencyValue = NotificationFrequency.oncePerDay;
        break;
      case '1日に3回':
        selectedFrequencyValue = NotificationFrequency.threeTimesPerDay;
        break;
      case '1週間に1回':
        selectedFrequencyValue = NotificationFrequency.oncePerWeek;
        break;
      default:
        selectedFrequencyValue = NotificationFrequency.unspecified;
    }
    frequencyProvider.setSelectedFrequency(selectedFrequencyValue);
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context);
    final frequencyProvider = Provider.of<FrequencyProvider>(context);

    final List<String> frequencyOptions = [
      '指定なし',
      '1日に1回',
      '1日に3回',
      '1週間に1回',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定画面'),
      ),
      body: SingleChildScrollView(
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
                  value: _selectedFrequency,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFrequency = newValue!;
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: '¥',
                suffixText: '円',
              ),
              onChanged: (value) {
                final amount = int.tryParse(value);
                if (amount != null) {
                  _updateAmount(amount);
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _apply,
              child: const Text('設定を反映する'),
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

String _getSelectedFrequencyText(NotificationFrequency frequency) {
  switch (frequency) {
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
}
