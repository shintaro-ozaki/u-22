import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'footer.dart';
import 'main.dart';
import 'AroundSpot.dart';
import './components/AmountProvider.dart';
import './components/FrequencyProvider.dart';
import './components/NotifierProvider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
  bool _notificationSwitchValue = false;
  int _amount = 0;
  NotificationFrequency _selectedFrequency = NotificationFrequency.unspecified;
  final notificationSettingsProvider = NotificationSettingsProvider();

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

  void _toggleNotification(bool value) {
    setState(() {
      _notificationSwitchValue = value;
      notificationSettingsProvider.updateNotificationSwitchValue(value);
    });
  }

  void _updateAmount(int value) {
    setState(() {
      _amount = value;
    });
  }

  void _applyAmount() {
    final amountProvider = Provider.of<AmountProvider>(context, listen: false);
    amountProvider.setAmount(_amount);
  }

  void _applyFrequency() {
    final frequencyProvider =
        Provider.of<FrequencyProvider>(context, listen: false);
    frequencyProvider.setSelectedFrequency(_selectedFrequency);
  }

  @override
  Widget build(BuildContext context) {
    final amountProvider = Provider.of<AmountProvider>(context);
    final notificationSettingsProvider =
        Provider.of<NotificationSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通知設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('通知を受け取る'),
              value: notificationSettingsProvider.notificationSwitchValue,
              onChanged: (newValue) {
                notificationSettingsProvider
                    .updateNotificationSwitchValue(newValue);
                _notificationSwitchValue = newValue;
                _toggleNotification(newValue);
              },
            ),
            const SizedBox(height: 20),
            if (_notificationSwitchValue)
              Column(
                children: [
                  DropdownButton<NotificationFrequency>(
                    value: _selectedFrequency,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFrequency = newValue!;
                      });
                    },
                    // ignore: prefer_const_literals_to_create_immutables
                    items: [
                      const DropdownMenuItem(
                        value: NotificationFrequency.unspecified,
                        child: Text('指定しない'),
                      ),
                      const DropdownMenuItem(
                        value: NotificationFrequency.oncePerDay,
                        child: Text('1日に1回'),
                      ),
                      const DropdownMenuItem(
                        value: NotificationFrequency.threeTimesPerDay,
                        child: Text('1日に3回'),
                      ),
                      const DropdownMenuItem(
                        value: NotificationFrequency.oncePerWeek,
                        child: Text('1週間に1回'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _applyFrequency,
                    child: const Text('適用する'),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '現在の設定:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedFrequency == NotificationFrequency.unspecified
                            ? '指定なし'
                            : _selectedFrequency.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyAmount,
              child: const Text('金額を設定'),
            ),
            Text('現在の金額: ${amountProvider.amount} 円'),
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
