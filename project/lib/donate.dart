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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'u-22 dev')),
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
        Uri.parse('http://127.0.0.1:5001/v2/codes'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "merchantPaymentId": merchantPaymentId,
          "codeType": "ORDER_QR",
          "redirectUrl": "https://google.com",
          "redirectType": "WEB_LINK",
          "orderDescription": "Example - Mune Cake shop",
          "orderItems": [
            {
              "name": "Moon cake",
              "category": "pasteries",
              "quantity": 1,
              "productId": "67678",
              "unitPrice": {"amount": 1, "currency": "JPY"},
            }
          ],
          "amount": {"amount": 1, "currency": "JPY"},
        }),
      );

      if (response.statusCode == 200) {
        // 成功時の処理
        print('寄付が成功しました');

        final responseBody = jsonDecode(response.body);
        final redirectUrl =
            responseBody['redirectUrl']; // レスポンスからredirectUrlを取得
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          print(redirectUrl);
          await launch(redirectUrl);
          // https://google.com
        }
      } else {
        // エラー時の処理
        print('寄付が失敗しました');
      }
    } catch (e) {
      // POSTリクエスト中の例外処理
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('募金ページです。'),
            ElevatedButton(
              onPressed: _onDonateButtonPressed, // ボタンが押された時に呼ばれるメソッド
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
