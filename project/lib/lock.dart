import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

Future<bool> checkPermission() async {
  PermissionStatus permissionLocation = await Permission.location.request();
  PermissionStatus permissionNotification =
      await Permission.notification.request();
  debugPrint(permissionLocation.toString());
  debugPrint(permissionNotification.toString());
  return permissionLocation.isGranted && permissionNotification.isGranted;
}

class LockPage extends StatefulWidget {
  const LockPage({super.key, required this.title});
  final String title;

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 2),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) async {
        if (await checkPermission()) {
          timer.cancel();
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MyHomePage(title: 'ホーム')),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TextButton(
        child: const Text('botton'),
        onPressed: () {
          openAppSettings();
        },
      ),
    );
  }
}
