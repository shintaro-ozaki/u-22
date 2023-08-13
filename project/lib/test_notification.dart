// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // デバイストークンを取得する
//   String? token = await FirebaseMessaging.instance.getToken();
//   print('デバイストークン: $token');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const MyFirestorePage(),
//     );
//   }
// }

// class MyFirestorePage extends StatefulWidget {
//   const MyFirestorePage({super.key});

//   @override
//   _MyFirestorePageState createState() => _MyFirestorePageState();
// }

// class _MyFirestorePageState extends State<MyFirestorePage> {
//   // プッシュ通知用
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   @override
//   void initState() {
//     super.initState();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("フォアグラウンドでメッセージを受け取りました");
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;

//       if (notification != null && android != null) {
//         // フォアグラウンドで通知を受け取った場合、通知を作成して表示する
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             const NotificationDetails(
//               // 通知channelを設定する
//               android: AndroidNotificationDetails(
//                 'like_channel', // channelId
//                 'あなたの投稿へのコメント', // channelName
//                 // channelDescription
//                 icon: 'launch_background',
//               ),
//             ));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text("Push通知テスト"),
//       ),
//     );
//   }
// }
