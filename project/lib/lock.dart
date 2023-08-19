import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  await Permission.location.request();
  await Permission.notification.request();
  var permissionLocation = await Permission.location.status;
  var permissionNotification = await Permission.notification.status;
  debugPrint(permissionLocation.toString());
  debugPrint(permissionNotification.toString());
  if (permissionLocation.isDenied ||
      permissionNotification.isPermanentlyDenied) {
    return Future.value(false);
  }
  return Future.value(true);
}

class LockPage extends StatefulWidget {
  const LockPage({super.key, required this.title});
  final String title;

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Switch(
          value: _isSwitched,
          onChanged: (bool newValue) {
            setState(() {
              _isSwitched = newValue;
            });
          },
          activeColor: Colors.blue,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[300],
        ));
  }
}
