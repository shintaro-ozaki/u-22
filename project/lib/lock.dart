import 'package:flutter/material.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key, required this.title});
  final String title;

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 32),
              child: const Text('TextButton'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const TextButton(
                  onPressed: null,
                  child: Text('disabled'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('enabled'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {},
                  child: const Text('enabled'),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 32),
              child: const Text('OutlinedButton'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const OutlinedButton(
                  onPressed: null,
                  child: Text('disabled'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('enabled'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('enabled'),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 32),
              child: const Text('ElevatedButton'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const ElevatedButton(
                  onPressed: null,
                  child: Text('disabled'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('enabled'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 16,
                  ),
                  child: const Text('enabled'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
