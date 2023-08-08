import 'package:flutter/material.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Page'), // ページのタイトルを設定
      ),
      body: const Center(
        child: Text('This is the Donate Page'),
      ),
    );
  }
}
