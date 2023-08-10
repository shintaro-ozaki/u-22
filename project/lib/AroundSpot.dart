import 'package:flutter/material.dart';
import 'footer.dart';
import 'main.dart';
import 'settings.dart';

class AroundSpotPage extends StatefulWidget {
  const AroundSpotPage({Key? key}) : super(key: key);

  @override
  _AroundSpotPageState createState() => _AroundSpotPageState();
}

class _AroundSpotPageState extends State<AroundSpotPage> {
  int _selectedIndex = 1;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('近くのスポット'),
      ),
      body: const Center(
        child: Text('近くのスポットを表示します。'),
      ),
      bottomNavigationBar: Footer(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
