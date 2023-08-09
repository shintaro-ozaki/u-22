import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const Footer({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city),
          label: '近くのスポット',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      ],
    );
  }
}
