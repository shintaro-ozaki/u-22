import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'footer.dart';
import 'main.dart';
import 'AroundSpot.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

String generateRandomString(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(characters[random.nextInt(characters.length)]);
  }

  return buffer.toString();
}

class DonatePage extends StatefulWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  int _selectedIndex = 0;
  int donationAmount = 0;

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
          // "redirectUrl": "app://main.dart",
          // "redirectType": "APP_DEEP_LINK",
          "redirectUrl": "",
          "redirectType": "WEB_LINK",
          "orderDescription": "募金グループへ",
          "orderItems": [
            {
              "name": "募金",
              "category": "pasteries",
              "quantity": 1,
              "productId": "67678",
              "unitPrice": {"amount": donationAmount, "currency": "JPY"},
            }
          ],
          "amount": {"amount": donationAmount, "currency": "JPY"},
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final redirectUrl = responseBody['redirectUrl'];
        await launch(redirectUrl);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'ホーム'), // 遷移先のウィジェットを指定
          ),
        );
      } else {
        print('寄付が失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募金ページ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('募金ページです'),
            const SizedBox(height: 100),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  donationAmount = int.tryParse(value) ?? 0;
                });
              },
              decoration: const InputDecoration(
                labelText: '募金額を入力してください',
                border: OutlineInputBorder(),
                prefixText: '¥',
                suffixText: '円',
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: donationAmount > 0 ? _onDonateButtonPressed : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('募金する'),
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
